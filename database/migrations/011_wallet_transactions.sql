-- Complete financial transaction ledger for virtual coin credits & debits
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    idempotency_key VARCHAR(255) UNIQUE, -- Prevents duplicate coin deduction/rewards
    amount NUMERIC(20, 0) NOT NULL, -- Positive for credit, negative for debit
    balance_after NUMERIC(20, 0) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'signup_bonus', 'daily_reward', 'game_boot', 'game_bet', 'game_win', 'admin_adjustment'
    reference_id UUID, -- Tied to game_id, reward_id, etc.
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_tx_user ON wallet_transactions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_idempotency ON wallet_transactions(idempotency_key) WHERE idempotency_key IS NOT NULL;
