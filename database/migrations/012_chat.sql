-- In-game table and room chat messages
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_id UUID REFERENCES tables(id) ON DELETE CASCADE,
    room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) NOT NULL DEFAULT 'text', -- 'text', 'emoji', 'gift'
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_table ON chat_messages(table_id, created_at DESC) WHERE table_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_chat_room ON chat_messages(room_id, created_at DESC) WHERE room_id IS NOT NULL;
