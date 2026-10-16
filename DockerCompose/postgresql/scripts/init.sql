CREATE USER app_user WITH PASSWORD :'app_password';
CREATE DATABASE app_db OWNER app_user;

\connect app_db app_user

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
    ('Иван Иванов', 'ivan@example.com'),
    ('Мария Петрова', 'maria@example.com')
ON CONFLICT (email) DO NOTHING;
