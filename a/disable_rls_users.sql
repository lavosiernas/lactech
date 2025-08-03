-- Script para desabilitar RLS temporariamente na tabela users
-- Isso permitirá que o sistema volte a funcionar

-- Desabilitar RLS na tabela users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas da tabela users
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- Verificar se RLS foi desabilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'users';

-- Verificar se não há mais políticas
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'users';

COMMIT;