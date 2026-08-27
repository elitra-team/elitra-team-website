DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'users' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON users', pol.policyname);
  END LOOP;
END
$$;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth_id = auth.uid()::text);

CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth_id = auth.uid()::text);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth_id = auth.uid()::text)
  WITH CHECK (auth_id = auth.uid()::text);
