-- =====================================================
-- CORRIGIR FUNÇÃO GET_USER_PROFILE
-- =====================================================

-- Remover a função existente se houver
DROP FUNCTION IF EXISTS get_user_profile();

-- Recriar a função get_user_profile com sintaxe correta
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
    WHERE u.id = auth.uid() AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VERIFICAR SE A FUNÇÃO FOI CRIADA
-- =====================================================
SELECT 
    proname as function_name,
    prosrc as function_source
FROM pg_proc 
WHERE proname = 'get_user_profile';

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'FUNÇÃO GET_USER_PROFILE CORRIGIDA! A função foi recriada com sintaxe correta.' as resultado;