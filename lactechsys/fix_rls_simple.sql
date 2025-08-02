-- SCRIPT SIMPLES - Desabilitar RLS Temporariamente
-- Use este script se o anterior não funcionar

-- 1. DESABILITAR RLS COMPLETAMENTE (TEMPORARIAMENTE)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS
DROP POLICY IF EXISTS allow_authenticated_delete ON users;
DROP POLICY IF EXISTS allow_authenticated_insert ON users;
DROP POLICY IF EXISTS allow_authenticated_update ON users;
DROP POLICY IF EXISTS allow_login_select ON users;
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

-- 3. VERIFICAR SE O RLS ESTÁ DESABILITADO
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename IN ('users', 'secondary_accounts');

-- 4. TESTAR CONSULTAS SIMPLES
-- Estas consultas devem funcionar agora
SELECT COUNT(*) as total_users FROM users;
SELECT farm_id FROM users WHERE email = 'devnasc@gmail.com' LIMIT 1;

-- 5. VERIFICAR SE NÃO HÁ MAIS POLÍTICAS
SELECT 
    schemaname,
    tablename,
    policyname
FROM pg_policies 
WHERE tablename IN ('users', 'secondary_accounts');

-- INSTRUÇÕES:
-- 1. Execute este script no Supabase SQL Editor
-- 2. Teste o sistema - deve funcionar sem erros 500
-- 3. Depois que estiver funcionando, podemos reabilitar o RLS com políticas simples 