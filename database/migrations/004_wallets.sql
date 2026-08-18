-- Wallets storing player virtual coins/chips & gems
CREATE TABLE IF NOT EXISTS wallets (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    chips_balance NUMERIC(20, 0) NOT NULL DEFAULT 10000 CHECK (chips_balance >= 0),
    gems_balance INT NOT NULL DEFAULT 50 CHECK (gems_balance >= 0),
    version INT NOT NULL DEFAULT 1, -- Optimistic concurrency control
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_chips ON wallets(chips_balance DESC);
