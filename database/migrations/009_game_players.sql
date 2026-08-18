-- Seated players participating in an active game session
CREATE TABLE IF NOT EXISTS game_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seat_index INT NOT NULL CHECK (seat_index BETWEEN 0 AND 6),
    cards_dealt JSONB, -- Stored encrypted/hashed for post-game audit & reconnection recovery
    is_blind BOOLEAN NOT NULL DEFAULT TRUE,
    has_seen_cards BOOLEAN NOT NULL DEFAULT FALSE,
    has_folded BOOLEAN NOT NULL DEFAULT FALSE,
    total_amount_bet NUMERIC(20, 0) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_game_seat UNIQUE (game_id, seat_index),
    CONSTRAINT uq_game_user UNIQUE (game_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_game_players_game ON game_players(game_id);
CREATE INDEX IF NOT EXISTS idx_game_players_user ON game_players(user_id);
