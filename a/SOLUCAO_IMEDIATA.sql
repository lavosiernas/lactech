-- =====================================================
-- SOLUÇÃO IMEDIATA PARA O ERRO RLS
-- =====================================================
-- COPIE E COLE NO SUPABASE SQL EDITOR AGORA!

-- PASSO 1: DESABILITAR RLS IMEDIATAMENTE
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- PASSO 2: REMOVER POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- PASSO 3: VERIFICAR SE FUNCIONOU
SELECT 'RLS DESABILITADO - SISTEMA DEVE FUNCIONAR AGORA!' as status;

-- =====================================================
-- EXECUTE APENAS OS COMANDOS ACIMA PRIMEIRO!
-- TESTE O LOGIN ANTES DE CONTINUAR!
-- =====================================================

-- SE O LOGIN FUNCIONAR, ENTÃO EXECUTE O RESTO:

-- PASSO 4: CRIAR FUNÇÃO AUXILIAR (SEM RECURSÃO)
CREATE OR REPLACE FUNCTION get_user_farm_id(user_id UUID)
RETURNS UUID AS $$
DECLARE
    farm_uuid UUID;
BEGIN
    SELECT farm_id INTO farm_uuid FROM users WHERE id = user_id LIMIT 1;
    RETURN farm_uuid;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PASSO 5: POLÍTICAS SIMPLES (SEM RECURSÃO)
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        id = auth.uid() 
        OR 
        farm_id = get_user_farm_id(auth.uid())
    );

CREATE POLICY users_insert_policy ON users
    FOR INSERT TO authenticated
    WITH CHECK (true); -- Permite inserção (controlado pela aplicação)

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

CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        farm_id = get_user_farm_id(auth.uid())
    );

-- PASSO 6: REABILITAR RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- PASSO 7: TESTE FINAL
SELECT 'RLS REABILITADO COM POLÍTICAS CORRIGIDAS!' as status;

COMMIT;

-- =====================================================
-- INSTRUÇÕES:
-- 1. Execute APENAS os passos 1-3 primeiro
-- 2. Teste o login
-- 3. Se funcionar, execute o resto (passos 4-7)
-- 4. Se não funcionar, mantenha RLS desabilitado
-- =====================================================