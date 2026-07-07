//! Core user domain models.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct User {
    pub id: String,
    pub username: String,
    pub role: String, // "admin" | "user"
    pub created_at: String,
    pub updated_at: String,
    // password_hash omitted for security
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NewUser {
    pub username: String,
    pub password_hash: Option<String>,
    pub role: String,
    pub oidc_sub: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UserUpdate {
    pub password_hash: Option<String>,
    pub role: Option<String>,
}
