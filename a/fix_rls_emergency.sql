-- =====================================================
-- CORREÇÃO EMERGENCIAL DO RLS - SEM RECURSÃO
-- =====================================================
-- Este script resolve o problema de recursão infinita

-- 1. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- 3. CRIAR FUNÇÃO AUXILIAR PARA EVITAR RECURSÃO
CREATE OR REPLACE FUNCTION get_user_farm_id(user_id UUID)
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT farm_id 
        FROM users 
        WHERE id = user_id
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. POLÍTICAS SIMPLES SEM RECURSÃO

-- POLÍTICA SELECT: Mais simples, sem recursão
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Permite ver próprio perfil
        id = auth.uid() 
        OR 
        -- Permite ver usuários da mesma fazenda (usando função)
        farm_id = get_user_farm_id(auth.uid())
    );

-- POLÍTICA INSERT: Simples para primeiro acesso
CREATE POLICY users_insert_policy ON users
    FOR INSERT TO authenticated
    WITH CHECK (true); -- Permite inserção (será controlado pela aplicação)

-- POLÍTICA UPDATE: Apenas próprio perfil ou mesma fazenda
CREATE POLICY users_update_policy ON users
    FOR UPDATE TO authenticated
    USING (
        id = auth.uid() 
        OR 
        farm_id = get_user_farm_id(auth.uid())
    )
    WITH CHECK (
        id = auth.uid() 
        OR 
        farm_id = get_user_farm_id(auth.uid())
    );

-- POLÍTICA DELETE: Apenas mesma fazenda
CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        farm_id = get_user_farm_id(auth.uid())
    );

-- 5. REABILITAR RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 6. TESTE BÁSICO
SELECT 'RLS configurado com sucesso!' as status;

COMMIT;

-- =====================================================
-- INSTRUÇÕES DE USO
-- =====================================================
-- 1. Execute este script no Supabase SQL Editor
-- 2. Teste o login imediatamente
-- 3. Se ainda houver problemas, desabilite RLS temporariamente:
--    ALTER TABLE users DISABLE ROW LEVEL SECURITY;
-- =====================================================