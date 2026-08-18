-- Individual Teen Patti game round sessions
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    round_number INT NOT NULL DEFAULT 1,
    boot_amount NUMERIC(20, 0) NOT NULL,
    total_pot NUMERIC(20, 0) NOT NULL DEFAULT 0,
    current_bet NUMERIC(20, 0) NOT NULL,
    current_turn_seat INT NOT NULL DEFAULT 0,
    winner_user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- References user directly to avoid circular dependency with game_players
    winning_hand_type VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress', -- 'in_progress', 'completed', 'aborted'
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_games_table ON games(table_id, status);
