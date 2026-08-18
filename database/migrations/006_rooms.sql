-- Game rooms (Public lobbies & Private rooms with access codes)
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    room_code VARCHAR(10) UNIQUE,
    room_name VARCHAR(100) NOT NULL,
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    max_players INT NOT NULL DEFAULT 5 CHECK (max_players BETWEEN 2 AND 7),
    boot_amount NUMERIC(20, 0) NOT NULL CHECK (boot_amount > 0),
    chaal_limit NUMERIC(20, 0) NOT NULL CHECK (chaal_limit >= boot_amount),
    pot_limit NUMERIC(20, 0) NOT NULL CHECK (pot_limit >= chaal_limit),
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'closed'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rooms_code ON rooms(room_code) WHERE is_private IS TRUE;
CREATE INDEX IF NOT EXISTS idx_rooms_boot ON rooms(boot_amount, is_private);
