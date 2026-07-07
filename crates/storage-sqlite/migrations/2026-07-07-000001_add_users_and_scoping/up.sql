-- Multi-user support (primarily for web/server mode).
-- Introduces `users` table and `user_id` scoping column on all user-owned data.
-- Legacy (single-user) data is backfilled to a default 'admin' user.
-- Desktop uses a single implicit admin user; no user switching UI.
-- Global reference data (assets, quotes, platforms, taxonomies, app_settings, market providers, most sync tables) remain unscoped.

-- 1. Users table (auth + ownership root)
CREATE TABLE users (
    id TEXT PRIMARY KEY NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    oidc_sub TEXT UNIQUE,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

-- Placeholder admin row. The application bootstrap code (server main_lib or tauri)
-- will ensure the password_hash is set from WF_DEFAULT_ADMIN_PASSWORD_HASH (if provided)
-- and role is 'admin'. Username is fixed to 'admin' per design.
INSERT INTO users (id, username, role, created_at, updated_at)
VALUES (
    lower(hex(randomblob(16))),
    'admin',
    'admin',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
);

-- 2. Add user_id (NOT NULL after backfill) + indexes to user-owned tables.
-- We use a two-step add + update because we need a real FK value from the admin row.
-- Application code will always supply user_id on inserts going forward.

-- accounts (root of most user data)
ALTER TABLE accounts ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE accounts SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts (user_id);

-- activities
ALTER TABLE activities ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE activities SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities (user_id);

-- goals + related
ALTER TABLE goals ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE goals SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals (user_id);

ALTER TABLE goal_plans ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE goal_plans SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_goal_plans_user_id ON goal_plans (user_id);

ALTER TABLE goals_allocation ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE goals_allocation SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_goals_allocation_user_id ON goals_allocation (user_id);

-- contribution limits
ALTER TABLE contribution_limits ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE contribution_limits SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_contribution_limits_user_id ON contribution_limits (user_id);

-- portfolio / lots / valuation / snapshots
ALTER TABLE portfolios ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE portfolios SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_portfolios_user_id ON portfolios (user_id);

ALTER TABLE portfolio_accounts ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE portfolio_accounts SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_portfolio_accounts_user_id ON portfolio_accounts (user_id);

ALTER TABLE lots ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE lots SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_lots_user_id ON lots (user_id);

ALTER TABLE lot_disposals ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE lot_disposals SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_lot_disposals_user_id ON lot_disposals (user_id);

ALTER TABLE holdings_snapshots ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE holdings_snapshots SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_holdings_snapshots_user_id ON holdings_snapshots (user_id);

ALTER TABLE snapshot_positions ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE snapshot_positions SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_snapshot_positions_user_id ON snapshot_positions (user_id);

ALTER TABLE daily_account_valuation ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE daily_account_valuation SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_daily_account_valuation_user_id ON daily_account_valuation (user_id);

-- allocation targets
ALTER TABLE allocation_targets ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE allocation_targets SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_allocation_targets_user_id ON allocation_targets (user_id);

ALTER TABLE allocation_target_weights ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE allocation_target_weights SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_allocation_target_weights_user_id ON allocation_target_weights (user_id);

ALTER TABLE allocation_target_constraints ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE allocation_target_constraints SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_allocation_target_constraints_user_id ON allocation_target_constraints (user_id);

-- ai chat (per-user history)
ALTER TABLE ai_threads ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE ai_threads SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_ai_threads_user_id ON ai_threads (user_id);

ALTER TABLE ai_messages ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE ai_messages SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_ai_messages_user_id ON ai_messages (user_id);

ALTER TABLE ai_thread_tags ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE ai_thread_tags SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_ai_thread_tags_user_id ON ai_thread_tags (user_id);

-- imports
ALTER TABLE import_runs ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE import_runs SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_import_runs_user_id ON import_runs (user_id);

ALTER TABLE import_account_templates ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE import_account_templates SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_import_account_templates_user_id ON import_account_templates (user_id);

-- activity taxonomy assignments (user data)
ALTER TABLE activity_taxonomy_assignments ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE activity_taxonomy_assignments SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_activity_taxonomy_assignments_user_id ON activity_taxonomy_assignments (user_id);

-- spending module (user-specific)
ALTER TABLE spending_events ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE spending_events SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_spending_events_user_id ON spending_events (user_id);

ALTER TABLE spending_activity_splits ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE spending_activity_splits SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_spending_activity_splits_user_id ON spending_activity_splits (user_id);

ALTER TABLE spending_activity_events ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE spending_activity_events SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_spending_activity_events_user_id ON spending_activity_events (user_id);

ALTER TABLE spending_categorization_rules ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE spending_categorization_rules SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_spending_categorization_rules_user_id ON spending_categorization_rules (user_id);

-- budgets (user)
ALTER TABLE budget_targets ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE budget_targets SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_budget_targets_user_id ON budget_targets (user_id);

ALTER TABLE budget_rollover_settings ADD COLUMN user_id TEXT NOT NULL DEFAULT '';
UPDATE budget_rollover_settings SET user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1) WHERE user_id = '';
CREATE INDEX IF NOT EXISTS idx_budget_rollover_settings_user_id ON budget_rollover_settings (user_id);

-- Note: brokers_sync_state links to accounts, so inherits scoping via account queries.
-- No direct user_id added here to avoid duplication.
