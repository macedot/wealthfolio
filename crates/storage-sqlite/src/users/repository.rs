//! Repository for user management (auth users).

use diesel::prelude::*;
use diesel::r2d2::{self, Pool};
use diesel::sqlite::SqliteConnection;
use std::sync::Arc;

use crate::db::{get_connection, WriteHandle};
use crate::errors::StorageError;
use crate::schema::users;
use crate::users::model::{NewUserDB, UserDB};
use async_trait::async_trait;
use uuid::Uuid;

pub struct UserRepository {
    pool: Arc<Pool<r2d2::ConnectionManager<SqliteConnection>>>,
    writer: WriteHandle,
}

impl UserRepository {
    pub fn new(
        pool: Arc<Pool<r2d2::ConnectionManager<SqliteConnection>>>,
        writer: WriteHandle,
    ) -> Self {
        Self { pool, writer }
    }

    /// Synchronous lookup by username (used during auth flows).
    pub fn get_by_username(&self, uname: &str) -> Result<Option<UserDB>, StorageError> {
        let mut conn = get_connection(&self.pool)?;
        users::table
            .filter(users::username.eq(uname))
            .select(UserDB::as_select())
            .first::<UserDB>(&mut conn)
            .optional()
            .map_err(StorageError::from)
    }

    /// Lookup by id.
    pub fn get_by_id(&self, uid: &str) -> Result<Option<UserDB>, StorageError> {
        let mut conn = get_connection(&self.pool)?;
        users::table
            .find(uid)
            .select(UserDB::as_select())
            .first::<UserDB>(&mut conn)
            .optional()
            .map_err(StorageError::from)
    }

    /// List all users (admin only).
    pub fn list_all(&self) -> Result<Vec<UserDB>, StorageError> {
        let mut conn = get_connection(&self.pool)?;
        users::table
            .select(UserDB::as_select())
            .order(users::created_at.asc())
            .load::<UserDB>(&mut conn)
            .map_err(StorageError::from)
    }

    /// Create or get the admin user. Used for bootstrap.
    pub async fn ensure_admin(&self, password_hash: Option<&str>) -> Result<UserDB, StorageError> {
        // Try find first
        if let Some(existing) = self.get_by_username("admin")? {
            if let Some(h) = password_hash {
                if existing.password_hash.as_deref() != Some(h) {
                    // Update hash
                    let updated = self
                        .update_password_hash(&existing.id, h)
                        .await?;
                    return Ok(updated);
                }
            }
            return Ok(existing);
        }

        // Create
        let new_id = Uuid::new_v4().to_string();
        let now = chrono::Utc::now().to_rfc3339();
        let new_user = NewUserDB {
            id: Some(new_id.clone()),
            username: "admin".to_string(),
            password_hash: password_hash.map(|s| s.to_string()),
            role: "admin".to_string(),
            oidc_sub: None,
            created_at: Some(now.clone()),
            updated_at: Some(now),
        };

        self.writer
            .exec_tx(move |tx| {
                diesel::insert_into(users::table)
                    .values(&new_user)
                    .execute(tx.conn())
                    .map_err(StorageError::from)?;
                // reload
                let loaded = users::table
                    .find(&new_id)
                    .select(UserDB::as_select())
                    .first::<UserDB>(tx.conn())
                    .map_err(StorageError::from)?;
                Ok(loaded)
            })
            .await
    }

    /// Update password hash for a user (admin reset or user change).
    pub async fn update_password_hash(&self, user_id: &str, new_hash: &str) -> Result<UserDB, StorageError> {
        let uid = user_id.to_string();
        let hash = new_hash.to_string();
        let now = chrono::Utc::now().to_rfc3339();

        self.writer
            .exec_tx(move |tx| {
                diesel::update(users::table.find(&uid))
                    .set((
                        users::password_hash.eq(Some(hash)),
                        users::updated_at.eq(now),
                    ))
                    .execute(tx.conn())
                    .map_err(StorageError::from)?;

                let loaded = users::table
                    .find(&uid)
                    .select(UserDB::as_select())
                    .first::<UserDB>(tx.conn())
                    .map_err(StorageError::from)?;
                Ok(loaded)
            })
            .await
    }

    pub async fn delete_user(&self, user_id: &str) -> Result<usize, StorageError> {
        let uid = user_id.to_string();
        self.writer
            .exec_tx(move |tx| {
                diesel::delete(users::table.find(&uid))
                    .execute(tx.conn())
                    .map_err(StorageError::from)
            })
            .await
    }

    /// Create a new user (for registration).
    pub async fn create_user(
        &self,
        username: String,
        password_hash: Option<String>,
        role: String,
        oidc_sub: Option<String>,
    ) -> Result<UserDB, StorageError> {
        let new_id = Uuid::new_v4().to_string();
        let now = chrono::Utc::now().to_rfc3339();
        let new_rec = NewUserDB {
            id: Some(new_id.clone()),
            username,
            password_hash,
            role,
            oidc_sub,
            created_at: Some(now.clone()),
            updated_at: Some(now),
        };

        self.writer
            .exec_tx(move |tx| {
                diesel::insert_into(users::table)
                    .values(&new_rec)
                    .execute(tx.conn())
                    .map_err(StorageError::from)?;

                let loaded = users::table
                    .find(&new_id)
                    .select(UserDB::as_select())
                    .first::<UserDB>(tx.conn())
                    .map_err(StorageError::from)?;
                Ok(loaded)
            })
            .await
    }
}
