//! User repository and service traits.

use async_trait::async_trait;

use crate::errors::Result;
use crate::users::{NewUser, User, UserUpdate};

#[async_trait]
pub trait UserRepositoryTrait: Send + Sync {
    async fn create(&self, new_user: NewUser) -> Result<User>;
    async fn get_by_id(&self, id: &str) -> Result<Option<User>>;
    async fn get_by_username(&self, username: &str) -> Result<Option<User>>;
    async fn list(&self) -> Result<Vec<User>>;
    async fn update(&self, id: &str, update: UserUpdate) -> Result<User>;
    async fn delete(&self, id: &str) -> Result<()>;
    async fn update_password_hash(&self, id: &str, password_hash: &str) -> Result<User>;
}
