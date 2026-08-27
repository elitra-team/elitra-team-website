CREATE OR REPLACE FUNCTION public.is_admin(uid text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE auth_id = uid AND admin = true
  );
$$;

REVOKE ALL ON FUNCTION public.is_admin(text) FROM public;
GRANT EXECUTE ON FUNCTION public.is_admin(text) TO authenticated;

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

CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (is_admin(auth.uid()::text));

CREATE POLICY "Admins can update all users"
  ON users FOR UPDATE
  USING (is_admin(auth.uid()::text))
  WITH CHECK (is_admin(auth.uid()::text));

CREATE POLICY "Admins can delete users"
  ON users FOR DELETE
  USING (is_admin(auth.uid()::text));
