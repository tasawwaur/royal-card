-- Active playing tables allocated on game servers
CREATE TABLE IF NOT EXISTS tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    server_id VARCHAR(100) NOT NULL, -- Identifies which game-server node hosts this table
    status VARCHAR(20) NOT NULL DEFAULT 'waiting', -- 'waiting', 'playing', 'closed'
    current_dealer_seat INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tables_room ON tables(room_id, status);
CREATE INDEX IF NOT EXISTS idx_tables_server ON tables(server_id);
