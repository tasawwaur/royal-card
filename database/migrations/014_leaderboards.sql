-- Periodic leaderboard snapshot rankings
CREATE TABLE IF NOT EXISTS leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_type VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'all_time'
    period_key VARCHAR(50) NOT NULL, -- e.g., '2026-W33' or '2026-08-14'
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rank INT NOT NULL,
    score NUMERIC(20, 0) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_leaderboard_entry UNIQUE (period_type, period_key, user_id)
);

CREATE INDEX IF NOT EXISTS idx_leaderboards_rank ON leaderboards(period_type, period_key, rank ASC);
