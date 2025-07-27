-- Função para atualizar configurações de relatório do usuário
-- Sistema LacTech - Gestão de Fazendas Leiteiras

CREATE OR REPLACE FUNCTION update_user_report_settings(
    p_report_farm_name TEXT DEFAULT NULL,
    p_report_farm_logo_base64 TEXT DEFAULT NULL,
    p_report_footer_text TEXT DEFAULT NULL,
    p_report_system_logo_base64 TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE users 
    SET 
        report_farm_name = COALESCE(p_report_farm_name, report_farm_name),
        report_farm_logo_base64 = COALESCE(p_report_farm_logo_base64, report_farm_logo_base64),
        report_footer_text = COALESCE(p_report_footer_text, report_footer_text),
        report_system_logo_base64 = COALESCE(p_report_system_logo_base64, report_system_logo_base64),
        updated_at = NOW()
    WHERE id = auth.uid();
    
    RETURN FOUND;
END;
$$;

-- Comentários sobre a função
COMMENT ON FUNCTION update_user_report_settings IS 'Atualiza as configurações de relatório específicas do usuário autenticado';