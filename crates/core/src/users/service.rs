//! User service (auth user management).

use async_trait::async_trait;
use std::sync::Arc;

use crate::errors::Result;
use crate::users::{NewUser, User, UserRepositoryTrait, UserUpdate};

pub struct UserService {
    repo: Arc<dyn UserRepositoryTrait + Send + Sync>,
}

impl UserService {
    pub fn new(repo: Arc<dyn UserRepositoryTrait + Send + Sync>) -> Self {
        Self { repo }
    }
}

#[async_trait]
pub trait UserServiceTrait: Send + Sync {
    async fn create_user(&self, new_user: NewUser) -> Result<User>;
    async fn list_users(&self) -> Result<Vec<User>>;
    async fn delete_user(&self, id: &str) -> Result<()>;
    async fn reset_password(&self, id: &str, new_password_hash: &str) -> Result<User>;
    async fn get_user_by_username(&self, username: &str) -> Result<Option<User>>;
}

#[async_trait]
impl UserServiceTrait for UserService {
    async fn create_user(&self, new_user: NewUser) -> Result<User> {
        self.repo.create(new_user).await
    }

    async fn list_users(&self) -> Result<Vec<User>> {
        self.repo.list().await
    }

    async fn delete_user(&self, id: &str) -> Result<()> {
        self.repo.delete(id).await
    }

    async fn reset_password(&self, id: &str, new_password_hash: &str) -> Result<User> {
        self.repo.update_password_hash(id, new_password_hash).await
    }

    async fn get_user_by_username(&self, username: &str) -> Result<Option<User>> {
        self.repo.get_by_username(username).await
    }
}
