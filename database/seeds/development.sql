-- Development Seed Data
INSERT INTO users (id, phone_number, email, auth_provider) VALUES
('00000000-0000-0000-0000-000000000001', '+919999999991', 'player1@teenpatti.com', 'phone'),
('00000000-0000-0000-0000-000000000002', '+919999999992', 'player2@teenpatti.com', 'phone'),
('00000000-0000-0000-0000-000000000003', '+919999999993', 'player3@teenpatti.com', 'guest')
ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (user_id, username, level, xp) VALUES
('00000000-0000-0000-0000-000000000001', 'KingPatti', 5, 2400),
('00000000-0000-0000-0000-000000000002', 'RoyalFlush99', 3, 1100),
('00000000-0000-0000-0000-000000000003', 'GuestPlayer', 1, 100)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO wallets (user_id, chips_balance, gems_balance) VALUES
('00000000-0000-0000-0000-000000000001', 50000, 100),
('00000000-0000-0000-0000-000000000002', 25000, 50),
('00000000-0000-0000-0000-000000000003', 10000, 10)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO rooms (id, room_name, is_private, boot_amount, chaal_limit, pot_limit) VALUES
('10000000-0000-0000-0000-000000000001', 'Beginner Table', false, 100, 12800, 100000),
('10000000-0000-0000-0000-000000000002', 'High Rollers Club', false, 5000, 640000, 5000000)
ON CONFLICT (id) DO NOTHING;
