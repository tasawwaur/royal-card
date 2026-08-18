-- User profiles containing display attributes and player career statistics
CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL,
    avatar_url VARCHAR(500) NOT NULL DEFAULT 'default_avatar_1.png',
    level INT NOT NULL DEFAULT 1,
    xp BIGINT NOT NULL DEFAULT 0,
    total_games_played INT NOT NULL DEFAULT 0,
    total_games_won INT NOT NULL DEFAULT 0,
    total_chips_won NUMERIC(20, 0) NOT NULL DEFAULT 0,
    biggest_pot_won NUMERIC(20, 0) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON profiles(level DESC);
