//! Database models for users (multi-user auth, web mode primarily).

use diesel::prelude::*;
use serde::{Deserialize, Serialize};

/// DB model for users table.
#[derive(
    Queryable,
    Identifiable,
    AsChangeset,
    Selectable,
    PartialEq,
    Serialize,
    Deserialize,
    Debug,
    Clone,
)]
#[diesel(table_name = crate::schema::users)]
#[diesel(check_for_backend(diesel::sqlite::Sqlite))]
#[serde(rename_all = "camelCase")]
pub struct UserDB {
    pub id: String,
    pub username: String,
    pub password_hash: Option<String>,
    pub role: String,
    pub oidc_sub: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

/// For inserts.
#[derive(Insertable, Serialize, Deserialize, Debug, Clone)]
#[diesel(table_name = crate::schema::users)]
#[serde(rename_all = "camelCase")]
pub struct NewUserDB {
    pub id: Option<String>,
    pub username: String,
    pub password_hash: Option<String>,
    pub role: String,
    pub oidc_sub: Option<String>,
    pub created_at: Option<String>,
    pub updated_at: Option<String>,
}
