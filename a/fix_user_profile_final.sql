-- =====================================================
-- CORREÇÃO FINAL DA FUNÇÃO GET_USER_PROFILE
-- =====================================================

-- Remover função existente
DROP FUNCTION IF EXISTS get_user_profile();

-- Criar função que recebe o user_id como parâmetro
CREATE OR REPLACE FUNCTION get_user_profile(p_user_id UUID DEFAULT NULL)
RETURNS TABLE(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    farm_id UUID,
    farm_name TEXT,
    farm_city TEXT,
    farm_state TEXT,
    profile_photo_url TEXT,
    report_farm_name TEXT,
    report_farm_logo_base64 TEXT,
    report_footer_text TEXT,
    report_system_logo_base64 TEXT
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
        u.profile_photo_url,
        u.report_farm_name,
        u.report_farm_logo_base64,
        u.report_footer_text,
        u.report_system_logo_base64
    FROM users u
    LEFT JOIN farms f ON f.id = u.farm_id
    WHERE u.id = COALESCE(p_user_id, auth.uid()) AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CRIAR FUNÇÃO ALTERNATIVA SEM AUTH.UID()
-- =====================================================
CREATE OR REPLACE FUNCTION get_user_profile_simple(p_user_id UUID)
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
    WHERE u.id = p_user_id AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VERIFICAR ESTRUTURA DA TABELA USERS
-- =====================================================
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- =====================================================
-- VERIFICAR ESTRUTURA DA TABELA FARMS
-- =====================================================
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'farms' 
ORDER BY ordinal_position;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'FUNÇÕES CRIADAS! Verifique a estrutura das tabelas acima.' as resultado; 