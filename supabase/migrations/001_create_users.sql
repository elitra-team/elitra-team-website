-- =============================================
-- Таблица пользователей
-- =============================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL DEFAULT 'Томат',
  username TEXT,
  email TEXT,
  avatar_url TEXT,
  admin BOOLEAN DEFAULT FALSE,
  tomato_type TEXT DEFAULT 'cherry',
  tomato_color TEXT DEFAULT '#ef4444',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- RLS (Row Level Security)
-- =============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Политика: каждый видит только свой профиль
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (
    auth_id = coalesce(
      current_setting('request.jwt.claims', true)::json->>'sub',
      ''
    )
  );

-- Политика: админы видят всех
CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE auth_id = coalesce(
        current_setting('request.jwt.claims', true)::json->>'sub',
        ''
      )
      AND admin = true
    )
  );

-- Политика: каждый обновляет только свой профиль
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (
    auth_id = coalesce(
      current_setting('request.jwt.claims', true)::json->>'sub',
      ''
    )
  )
  WITH CHECK (
    auth_id = coalesce(
      current_setting('request.jwt.claims', true)::json->>'sub',
      ''
    )
  );

-- Политика: админы могут обновлять всех
CREATE POLICY "Admins can update all users"
  ON users FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE auth_id = coalesce(
        current_setting('request.jwt.claims', true)::json->>'sub',
        ''
      )
      AND admin = true
    )
  );

-- Политика: админы могут удалять пользователей
CREATE POLICY "Admins can delete users"
  ON users FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE auth_id = coalesce(
        current_setting('request.jwt.claims', true)::json->>'sub',
        ''
      )
      AND admin = true
    )
  );

-- =============================================
-- Функция для автоматического создания профиля
-- =============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (auth_id, display_name, avatar_url, email)
  VALUES (
    NEW.id,
    coalesce(NEW.raw_user_meta_data->>'full_name', 'Томат'),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Триггер: при регистрации в Supabase Auth создаётся профиль
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
