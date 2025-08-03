-- =====================================================
-- CORREÇÃO COMPLETA COM LIMPEZA DE POLÍTICAS
-- =====================================================

-- 1. REMOVER POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS farms_select_policy ON farms;
DROP POLICY IF EXISTS farms_insert_policy ON farms;
DROP POLICY IF EXISTS farms_update_policy ON farms;
DROP POLICY IF EXISTS farms_delete_policy ON farms;

DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

-- 2. ATIVAR RLS NAS TABELAS PRINCIPAIS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS PERMISSIVAS NOVAS
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true);
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- 4. CRIAR FUNÇÃO GET_USER_PROFILE SIMPLIFICADA
DROP FUNCTION IF EXISTS get_user_profile();

CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    farm_id UUID,
    farm_name TEXT,
    farm_city TEXT,
    farm_state TEXT,
    profile_photo_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.name as user_name,
        u.email as user_email,
        u.role as user_role,
        u.farm_id,
        f.name as farm_name,
        f.city as farm_city,
        f.state as farm_state,
        u.profile_photo_url
    FROM users u
    LEFT JOIN farms f ON f.id = u.farm_id
    WHERE u.id = auth.uid() AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. MENSAGEM FINAL
SELECT 'SISTEMA CORRIGIDO! Políticas limpas, RLS ativado e função get_user_profile criada.' as resultado; 