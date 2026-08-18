-- Immutable turn action log for each game move
CREATE TABLE IF NOT EXISTS game_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seat_index INT NOT NULL,
    action_type VARCHAR(30) NOT NULL, -- 'boot', 'pack', 'chaal', 'raise', 'see_cards', 'sideshow_request', 'sideshow_response', 'show'
    amount NUMERIC(20, 0) NOT NULL DEFAULT 0,
    pot_after_action NUMERIC(20, 0) NOT NULL,
    metadata JSONB, -- Additional details e.g., sideshow opponent seat, show result
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_game_actions_game ON game_actions(game_id, created_at);
