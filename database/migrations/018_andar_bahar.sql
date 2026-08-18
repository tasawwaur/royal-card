-- Andar Bahar Game Rounds & Bets Ledger
CREATE TABLE IF NOT EXISTS andar_bahar_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_id UUID REFERENCES tables(id) ON DELETE CASCADE,
    joker_card JSONB NOT NULL,
    winning_spot VARCHAR(10), -- 'ANDAR' or 'BAHAR'
    total_dealt_cards INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'betting', -- 'betting', 'dealing', 'completed'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS andar_bahar_bets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES andar_bahar_games(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    spot VARCHAR(10) NOT NULL, -- 'ANDAR' or 'BAHAR'
    amount NUMERIC(20, 0) NOT NULL,
    payout_amount NUMERIC(20, 0) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ab_bets_game ON andar_bahar_bets(game_id);
