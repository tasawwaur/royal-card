-- Texas Hold'em Poker Game Rounds & Community Cards
CREATE TABLE IF NOT EXISTS poker_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_id UUID REFERENCES tables(id) ON DELETE CASCADE,
    small_blind NUMERIC(20, 0) NOT NULL,
    big_blind NUMERIC(20, 0) NOT NULL,
    pot NUMERIC(20, 0) NOT NULL DEFAULT 0,
    community_cards JSONB NOT NULL DEFAULT '[]'::jsonb, -- Flop (3), Turn (1), River (1)
    winner_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    winning_hand_rank VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'pre_flop',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_poker_games_table ON poker_games(table_id, status);
