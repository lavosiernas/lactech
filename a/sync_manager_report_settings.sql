-- Função para sincronizar configurações de relatório do gerente para todos os usuários da fazenda
-- Sistema LacTech - Gestão de Fazendas Leiteiras

CREATE OR REPLACE FUNCTION sync_manager_report_settings_to_farm()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    manager_farm_id UUID;
    manager_report_name TEXT;
    manager_report_logo TEXT;
    manager_report_footer TEXT;
    manager_report_system_logo TEXT;
BEGIN
    -- Verificar se o usuário atual é um gerente
    SELECT farm_id INTO manager_farm_id
    FROM users 
    WHERE id = auth.uid() AND role = 'gerente';
    
    IF manager_farm_id IS NULL THEN
        RAISE EXCEPTION 'Apenas gerentes podem sincronizar configurações de relatório';
    END IF;
    
    -- Obter as configurações de relatório do gerente
    SELECT 
        report_farm_name,
        report_farm_logo_base64,
        report_footer_text,
        report_system_logo_base64
    INTO 
        manager_report_name,
        manager_report_logo,
        manager_report_footer,
        manager_report_system_logo
    FROM users 
    WHERE id = auth.uid();
    
    -- Atualizar todos os usuários da mesma fazenda com as configurações do gerente
    UPDATE users 
    SET 
        report_farm_name = manager_report_name,
        report_farm_logo_base64 = manager_report_logo,
        report_footer_text = manager_report_footer,
        report_system_logo_base64 = manager_report_system_logo,
        updated_at = NOW()
    WHERE farm_id = manager_farm_id
    AND id != auth.uid(); -- Não atualizar o próprio gerente
    
    RETURN TRUE;
END;
$$;

-- Comentário sobre a função
COMMENT ON FUNCTION sync_manager_report_settings_to_farm IS 'Sincroniza as configurações de relatório do gerente para todos os usuários da fazenda';

-- Função modificada para salvar configurações do gerente e sincronizar automaticamente
CREATE OR REPLACE FUNCTION update_manager_report_settings(
    p_report_farm_name TEXT DEFAULT NULL,
    p_report_farm_logo_base64 TEXT DEFAULT NULL,
    p_report_footer_text TEXT DEFAULT NULL,
    p_report_system_logo_base64 TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    manager_farm_id UUID;
BEGIN
    -- Verificar se o usuário atual é um gerente
    SELECT farm_id INTO manager_farm_id
    FROM users 
    WHERE id = auth.uid() AND role = 'gerente';
    
    IF manager_farm_id IS NULL THEN
        RAISE EXCEPTION 'Apenas gerentes podem atualizar configurações de relatório';
    END IF;
    
    -- Atualizar as configurações do gerente
    UPDATE users 
    SET 
        report_farm_name = COALESCE(p_report_farm_name, report_farm_name),
        report_farm_logo_base64 = COALESCE(p_report_farm_logo_base64, report_farm_logo_base64),
        report_footer_text = COALESCE(p_report_footer_text, report_footer_text),
        report_system_logo_base64 = COALESCE(p_report_system_logo_base64, report_system_logo_base64),
        updated_at = NOW()
    WHERE id = auth.uid();
    
    -- Sincronizar para todos os usuários da fazenda
    UPDATE users 
    SET 
        report_farm_name = COALESCE(p_report_farm_name, report_farm_name),
        report_farm_logo_base64 = COALESCE(p_report_farm_logo_base64, report_farm_logo_base64),
        report_footer_text = COALESCE(p_report_footer_text, report_footer_text),
        report_system_logo_base64 = COALESCE(p_report_system_logo_base64, report_system_logo_base64),
        updated_at = NOW()
    WHERE farm_id = manager_farm_id
    AND id != auth.uid(); -- Não atualizar o próprio gerente novamente
    
    RETURN TRUE;
END;
$$;

-- Comentário sobre a função
COMMENT ON FUNCTION update_manager_report_settings IS 'Atualiza as configurações de relatório do gerente e sincroniza automaticamente para todos os usuários da fazenda';