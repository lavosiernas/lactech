-- =====================================================
-- TESTE SIMPLIFICADO DA FUNÇÃO GET_USER_PROFILE
-- =====================================================

-- Remover função existente
DROP FUNCTION IF EXISTS get_user_profile();

-- Criar versão simplificada
CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    farm_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.name as user_name,
        u.email as user_email,
        u.role as user_role,
        u.farm_id
    FROM users u
    WHERE u.id = auth.uid() AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- TESTAR A FUNÇÃO
-- =====================================================
SELECT 'FUNÇÃO SIMPLIFICADA CRIADA. Teste se o erro 400 persiste.' as resultado; 