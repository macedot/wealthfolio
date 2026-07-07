-- Best-effort reverse for multi-user migration.
-- SQLite limitations mean full column removal requires table rebuilds for most tables.
-- This down is intentionally partial; full downgrade of a multi-user DB is not supported.

DROP TABLE IF EXISTS users;

-- Drop indexes (safe if missing)
DROP INDEX IF EXISTS idx_accounts_user_id;
DROP INDEX IF EXISTS idx_activities_user_id;
DROP INDEX IF EXISTS idx_goals_user_id;
DROP INDEX IF EXISTS idx_goal_plans_user_id;
DROP INDEX IF EXISTS idx_goals_allocation_user_id;
DROP INDEX IF EXISTS idx_contribution_limits_user_id;
DROP INDEX IF EXISTS idx_portfolios_user_id;
DROP INDEX IF EXISTS idx_portfolio_accounts_user_id;
DROP INDEX IF EXISTS idx_lots_user_id;
DROP INDEX IF EXISTS idx_lot_disposals_user_id;
DROP INDEX IF EXISTS idx_holdings_snapshots_user_id;
DROP INDEX IF EXISTS idx_snapshot_positions_user_id;
DROP INDEX IF EXISTS idx_daily_account_valuation_user_id;
DROP INDEX IF EXISTS idx_allocation_targets_user_id;
DROP INDEX IF EXISTS idx_allocation_target_weights_user_id;
DROP INDEX IF EXISTS idx_allocation_target_constraints_user_id;
DROP INDEX IF EXISTS idx_ai_threads_user_id;
DROP INDEX IF EXISTS idx_ai_messages_user_id;
DROP INDEX IF EXISTS idx_ai_thread_tags_user_id;
DROP INDEX IF EXISTS idx_import_runs_user_id;
DROP INDEX IF EXISTS idx_import_account_templates_user_id;
DROP INDEX IF EXISTS idx_activity_taxonomy_assignments_user_id;
DROP INDEX IF EXISTS idx_spending_events_user_id;
DROP INDEX IF EXISTS idx_spending_activity_splits_user_id;
DROP INDEX IF EXISTS idx_spending_activity_events_user_id;
DROP INDEX IF EXISTS idx_spending_categorization_rules_user_id;
DROP INDEX IF EXISTS idx_budget_targets_user_id;
DROP INDEX IF EXISTS idx_budget_rollover_settings_user_id;

-- Attempt column drops (works on recent SQLite; ignore errors on older/tooling)
-- These are best-effort; a real downgrade would require full table rebuilds per table.
ALTER TABLE accounts DROP COLUMN user_id;
ALTER TABLE activities DROP COLUMN user_id;
ALTER TABLE goals DROP COLUMN user_id;
ALTER TABLE goal_plans DROP COLUMN user_id;
ALTER TABLE goals_allocation DROP COLUMN user_id;
ALTER TABLE contribution_limits DROP COLUMN user_id;
ALTER TABLE portfolios DROP COLUMN user_id;
ALTER TABLE portfolio_accounts DROP COLUMN user_id;
ALTER TABLE lots DROP COLUMN user_id;
ALTER TABLE lot_disposals DROP COLUMN user_id;
ALTER TABLE holdings_snapshots DROP COLUMN user_id;
ALTER TABLE snapshot_positions DROP COLUMN user_id;
ALTER TABLE daily_account_valuation DROP COLUMN user_id;
ALTER TABLE allocation_targets DROP COLUMN user_id;
ALTER TABLE allocation_target_weights DROP COLUMN user_id;
ALTER TABLE allocation_target_constraints DROP COLUMN user_id;
ALTER TABLE ai_threads DROP COLUMN user_id;
ALTER TABLE ai_messages DROP COLUMN user_id;
ALTER TABLE ai_thread_tags DROP COLUMN user_id;
ALTER TABLE import_runs DROP COLUMN user_id;
ALTER TABLE import_account_templates DROP COLUMN user_id;
ALTER TABLE activity_taxonomy_assignments DROP COLUMN user_id;
ALTER TABLE spending_events DROP COLUMN user_id;
ALTER TABLE spending_activity_splits DROP COLUMN user_id;
ALTER TABLE spending_activity_events DROP COLUMN user_id;
ALTER TABLE spending_categorization_rules DROP COLUMN user_id;
ALTER TABLE budget_targets DROP COLUMN user_id;
ALTER TABLE budget_rollover_settings DROP COLUMN user_id;
