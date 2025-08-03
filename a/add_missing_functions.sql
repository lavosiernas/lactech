-- =====================================================
-- ADICIONAR FUNÇÕES FALTANTES AO BANCO DE DADOS
-- =====================================================

-- Função get_user_profile que está sendo chamada mas não existe
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
    JOIN farms f ON f.id = u.farm_id
    WHERE u.id = auth.uid() AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter configurações do usuário
CREATE OR REPLACE FUNCTION get_user_settings(p_user_id UUID DEFAULT NULL)
RETURNS TABLE(
    setting_key TEXT,
    setting_value TEXT
) AS $$
DECLARE
    target_user_id UUID;
BEGIN
    -- Se não foi fornecido user_id, usar o usuário autenticado
    IF p_user_id IS NULL THEN
        target_user_id := auth.uid();
    ELSE
        target_user_id := p_user_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        fs.setting_key,
        fs.setting_value
    FROM farm_settings fs
    JOIN users u ON u.farm_id = fs.farm_id
    WHERE u.id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para atualizar configurações do usuário
CREATE OR REPLACE FUNCTION update_user_settings(
    p_setting_key TEXT,
    p_setting_value TEXT,
    p_user_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    target_user_id UUID;
    user_farm_id UUID;
BEGIN
    -- Se não foi fornecido user_id, usar o usuário autenticado
    IF p_user_id IS NULL THEN
        target_user_id := auth.uid();
    ELSE
        target_user_id := p_user_id;
    END IF;
    
    -- Obter farm_id do usuário
    SELECT farm_id INTO user_farm_id
    FROM users
    WHERE id = target_user_id;
    
    IF user_farm_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado';
    END IF;
    
    -- Inserir ou atualizar configuração
    INSERT INTO farm_settings (farm_id, setting_key, setting_value)
    VALUES (user_farm_id, p_setting_key, p_setting_value)
    ON CONFLICT (farm_id, setting_key)
    DO UPDATE SET 
        setting_value = EXCLUDED.setting_value,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter estatísticas do dashboard
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_farm_id UUID DEFAULT NULL)
RETURNS TABLE(
    total_animals INTEGER,
    total_production_today NUMERIC,
    total_production_month NUMERIC,
    active_users INTEGER,
    pending_payments INTEGER,
    quality_average NUMERIC
) AS $$
DECLARE
    target_farm_id UUID;
BEGIN
    -- Se não foi fornecido farm_id, usar o farm_id do usuário autenticado
    IF p_farm_id IS NULL THEN
        SELECT farm_id INTO target_farm_id
        FROM users
        WHERE id = auth.uid();
    ELSE
        target_farm_id := p_farm_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        COALESCE(COUNT(a.id), 0)::INTEGER as total_animals,
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) = CURRENT_DATE THEN mp.volume_liters ELSE 0 END), 0) as total_production_today,
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) >= DATE_TRUNC('month', CURRENT_DATE) THEN mp.volume_liters ELSE 0 END), 0) as total_production_month,
        COALESCE(COUNT(u.id), 0)::INTEGER as active_users,
        COALESCE(COUNT(p.id), 0)::INTEGER as pending_payments,
        COALESCE(AVG(qt.fat_percentage + qt.protein_percentage) / 2, 0) as quality_average
    FROM farms f
    LEFT JOIN animals a ON a.farm_id = f.id AND a.is_active = true
    LEFT JOIN milk_production mp ON mp.farm_id = f.id
    LEFT JOIN users u ON u.farm_id = f.id AND u.is_active = true
    LEFT JOIN payments p ON p.farm_id = f.id AND p.payment_status = 'pending'
    LEFT JOIN quality_tests qt ON qt.farm_id = f.id AND qt.test_date >= CURRENT_DATE - INTERVAL '30 days'
    WHERE f.id = target_farm_id
    GROUP BY f.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter histórico de produção
CREATE OR REPLACE FUNCTION get_production_history(
    p_farm_id UUID DEFAULT NULL,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    production_date DATE,
    total_volume NUMERIC,
    shift_count INTEGER,
    avg_temperature NUMERIC
) AS $$
DECLARE
    target_farm_id UUID;
BEGIN
    -- Se não foi fornecido farm_id, usar o farm_id do usuário autenticado
    IF p_farm_id IS NULL THEN
        SELECT farm_id INTO target_farm_id
        FROM users
        WHERE id = auth.uid();
    ELSE
        target_farm_id := p_farm_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        mp.production_date,
        SUM(mp.volume_liters) as total_volume,
        COUNT(*) as shift_count,
        AVG(mp.temperature) as avg_temperature
    FROM milk_production mp
    WHERE mp.farm_id = target_farm_id
    AND mp.production_date >= CURRENT_DATE - (p_days || ' days')::INTERVAL
    GROUP BY mp.production_date
    ORDER BY mp.production_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter dados de qualidade
CREATE OR REPLACE FUNCTION get_quality_data(
    p_farm_id UUID DEFAULT NULL,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    test_date DATE,
    fat_percentage NUMERIC,
    protein_percentage NUMERIC,
    somatic_cell_count INTEGER,
    quality_grade TEXT
) AS $$
DECLARE
    target_farm_id UUID;
BEGIN
    -- Se não foi fornecido farm_id, usar o farm_id do usuário autenticado
    IF p_farm_id IS NULL THEN
        SELECT farm_id INTO target_farm_id
        FROM users
        WHERE id = auth.uid();
    ELSE
        target_farm_id := p_farm_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        qt.test_date,
        qt.fat_percentage,
        qt.protein_percentage,
        qt.somatic_cell_count,
        qt.quality_grade
    FROM quality_tests qt
    WHERE qt.farm_id = target_farm_id
    AND qt.test_date >= CURRENT_DATE - (p_days || ' days')::INTERVAL
    ORDER BY qt.test_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter pagamentos
CREATE OR REPLACE FUNCTION get_payments_data(
    p_farm_id UUID DEFAULT NULL,
    p_status TEXT DEFAULT NULL
)
RETURNS TABLE(
    payment_id UUID,
    payment_date DATE,
    volume_liters NUMERIC,
    gross_amount NUMERIC,
    net_amount NUMERIC,
    payment_status TEXT,
    created_at TIMESTAMP
) AS $$
DECLARE
    target_farm_id UUID;
BEGIN
    -- Se não foi fornecido farm_id, usar o farm_id do usuário autenticado
    IF p_farm_id IS NULL THEN
        SELECT farm_id INTO target_farm_id
        FROM users
        WHERE id = auth.uid();
    ELSE
        target_farm_id := p_farm_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id as payment_id,
        p.payment_date,
        p.volume_liters,
        p.gross_amount,
        p.net_amount,
        p.payment_status,
        p.created_at
    FROM payments p
    WHERE p.farm_id = target_farm_id
    AND (p_status IS NULL OR p.payment_status = p_status)
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter usuários da fazenda
CREATE OR REPLACE FUNCTION get_farm_users_data(
    p_farm_id UUID DEFAULT NULL,
    p_role TEXT DEFAULT NULL
)
RETURNS TABLE(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    user_whatsapp TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP
) AS $$
DECLARE
    target_farm_id UUID;
BEGIN
    -- Se não foi fornecido farm_id, usar o farm_id do usuário autenticado
    IF p_farm_id IS NULL THEN
        SELECT farm_id INTO target_farm_id
        FROM users
        WHERE id = auth.uid();
    ELSE
        target_farm_id := p_farm_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.name as user_name,
        u.email as user_email,
        u.role as user_role,
        u.whatsapp as user_whatsapp,
        u.is_active,
        u.created_at
    FROM users u
    WHERE u.farm_id = target_farm_id
    AND (p_role IS NULL OR u.role = p_role)
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'FUNÇÕES FALTANTES ADICIONADAS COM SUCESSO! get_user_profile e outras funções foram criadas.' as resultado; 