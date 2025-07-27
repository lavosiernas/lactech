-- Script para corrigir o tipo de retorno da função get_user_profile
-- Incluindo campos de configuração de relatório

DROP FUNCTION IF EXISTS get_user_profile();

CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    farm_id UUID,
    farm_name TEXT,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    user_whatsapp TEXT,
    profile_photo_url TEXT,
    report_farm_name TEXT,
    report_farm_logo_base64 TEXT,
    report_footer_text TEXT,
    report_system_logo_base64 TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.farm_id,
        f.name::TEXT,
        u.name::TEXT,
        u.email::TEXT,
        u.role::TEXT,
        u.whatsapp::TEXT,
        u.profile_photo_url,
        COALESCE(u.report_farm_name, f.name)::TEXT as report_farm_name,
        u.report_farm_logo_base64,
        COALESCE(u.report_footer_text, 'LacTech Milk © ' || EXTRACT(YEAR FROM NOW()))::TEXT as report_footer_text,
        u.report_system_logo_base64
    FROM users u
    JOIN farms f ON u.farm_id = f.id
    WHERE u.id = auth.uid();
END;
$$;