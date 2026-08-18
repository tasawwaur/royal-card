-- Safe Atomic Coin Transfer & Deductions Stored Procedure
-- Features: Row-level locking (FOR UPDATE), idempotency check, ledger entry, non-negative balance enforcement
CREATE OR REPLACE FUNCTION transfer_chips(
    p_user_id UUID,
    p_amount NUMERIC,
    p_transaction_type VARCHAR(50),
    p_idempotency_key VARCHAR(255) DEFAULT NULL,
    p_reference_id UUID DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_balance NUMERIC;
    v_new_balance NUMERIC;
    v_existing_tx UUID;
    v_result JSONB;
BEGIN
    -- 1. Idempotency Check
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_existing_tx
        FROM wallet_transactions
        WHERE idempotency_key = p_idempotency_key;

        IF v_existing_tx IS NOT NULL THEN
            SELECT jsonb_build_object(
                'success', true,
                'already_processed', true,
                'transaction_id', v_existing_tx
            ) INTO v_result;
            RETURN v_result;
        END IF;
    END IF;

    -- 2. Lock target wallet row (FOR UPDATE)
    SELECT chips_balance INTO v_current_balance
    FROM wallets
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
    END IF;

    -- 3. Check sufficient balance if debiting
    v_new_balance := v_current_balance + p_amount;
    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'Insufficient chips balance. Current: %, Requested debit: %', v_current_balance, p_amount;
    END IF;

    -- 4. Update balance
    UPDATE wallets
    SET chips_balance = v_new_balance,
        version = version + 1,
        updated_at = NOW()
    WHERE user_id = p_user_id;

    -- 5. Insert ledger entry
    INSERT INTO wallet_transactions (
        user_id,
        idempotency_key,
        amount,
        balance_after,
        transaction_type,
        reference_id,
        description
    ) VALUES (
        p_user_id,
        p_idempotency_key,
        p_amount,
        v_new_balance,
        p_transaction_type,
        p_reference_id,
        p_description
    );

    SELECT jsonb_build_object(
        'success', true,
        'already_processed', false,
        'previous_balance', v_current_balance,
        'new_balance', v_new_balance
    ) INTO v_result;

    RETURN v_result;
END;
$$;
