-- =====================================================
-- FUNÇÕES RPC NECESSÁRIAS PARA O SISTEMA LACTECH
-- =====================================================

-- Função para verificar se fazenda já existe
CREATE OR REPLACE FUNCTION check_farm_exists(p_name TEXT, p_cnpj TEXT DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_cnpj IS NOT NULL AND p_cnpj != '' THEN
        RETURN EXISTS(SELECT 1 FROM farms WHERE name = p_name OR cnpj = p_cnpj);
    ELSE
        RETURN EXISTS(SELECT 1 FROM farms WHERE name = p_name);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se usuário já existe
CREATE OR REPLACE FUNCTION check_user_exists(p_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM users WHERE email = p_email);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para criar fazenda inicial
CREATE OR REPLACE FUNCTION create_initial_farm(
    p_name TEXT,
    p_owner_name TEXT,
    p_city TEXT,
    p_state TEXT,
    p_cnpj TEXT DEFAULT '',
    p_animal_count INTEGER DEFAULT 0,
    p_daily_production NUMERIC DEFAULT 0,
    p_total_area_hectares NUMERIC DEFAULT NULL,
    p_phone TEXT DEFAULT '',
    p_email TEXT DEFAULT '',
    p_address TEXT DEFAULT ''
)
RETURNS UUID AS $$
DECLARE
    farm_id UUID;
BEGIN
    INSERT INTO farms (
        name, owner_name, cnpj, city, state, 
        animal_count, daily_production, total_area_hectares,
        phone, email, address, is_active, created_at
    ) VALUES (
        p_name, p_owner_name, p_cnpj, p_city, p_state,
        p_animal_count, p_daily_production, p_total_area_hectares,
        p_phone, p_email, p_address, true, NOW()
    ) RETURNING id INTO farm_id;
    
    RETURN farm_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para criar usuário inicial
CREATE OR REPLACE FUNCTION create_initial_user(
    p_user_id UUID,
    p_farm_id UUID,
    p_name TEXT,
    p_email TEXT,
    p_role TEXT,
    p_whatsapp TEXT DEFAULT ''
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO users (
        id, farm_id, name, email, role, whatsapp, is_active, created_at
    ) VALUES (
        p_user_id, p_farm_id, p_name, p_email, p_role, p_whatsapp, true, NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para completar configuração da fazenda
CREATE OR REPLACE FUNCTION complete_farm_setup(p_farm_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE farms 
    SET is_configured = true, updated_at = NOW()
    WHERE id = p_farm_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter estatísticas da fazenda
CREATE OR REPLACE FUNCTION get_farm_statistics(p_farm_id UUID)
RETURNS TABLE(
    total_animals INTEGER,
    total_production_today NUMERIC,
    total_production_month NUMERIC,
    active_users INTEGER,
    pending_payments INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(COUNT(a.id), 0)::INTEGER as total_animals,
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) = CURRENT_DATE THEN mp.quantity ELSE 0 END), 0) as total_production_today,
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) >= DATE_TRUNC('month', CURRENT_DATE) THEN mp.quantity ELSE 0 END), 0) as total_production_month,
        COALESCE(COUNT(u.id), 0)::INTEGER as active_users,
        COALESCE(COUNT(p.id), 0)::INTEGER as pending_payments
    FROM farms f
    LEFT JOIN animals a ON a.farm_id = f.id AND a.is_active = true
    LEFT JOIN milk_production mp ON mp.farm_id = f.id
    LEFT JOIN users u ON u.farm_id = f.id AND u.is_active = true
    LEFT JOIN payments p ON p.farm_id = f.id AND p.status = 'pending'
    WHERE f.id = p_farm_id
    GROUP BY f.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter políticas de uma tabela (para debug)
CREATE OR REPLACE FUNCTION get_policies_for_table(table_name TEXT)
RETURNS TABLE(
    schemaname TEXT,
    tablename TEXT,
    policyname TEXT,
    permissive TEXT,
    roles TEXT,
    cmd TEXT,
    qual TEXT,
    with_check TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.schemaname::TEXT,
        p.tablename::TEXT,
        p.policyname::TEXT,
        p.permissive::TEXT,
        p.roles::TEXT,
        p.cmd::TEXT,
        p.qual::TEXT,
        p.with_check::TEXT
    FROM pg_policies p
    WHERE p.tablename = table_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se fazenda está configurada
CREATE OR REPLACE FUNCTION is_farm_configured(p_farm_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(SELECT 1 FROM farms WHERE id = p_farm_id AND is_configured = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter dados do usuário atual
CREATE OR REPLACE FUNCTION get_current_user_data()
RETURNS TABLE(
    user_id UUID,
    farm_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    farm_name TEXT,
    farm_city TEXT,
    farm_state TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.farm_id,
        u.name as user_name,
        u.email as user_email,
        u.role as user_role,
        f.name as farm_name,
        f.city as farm_city,
        f.state as farm_state
    FROM users u
    JOIN farms f ON f.id = u.farm_id
    WHERE u.id = auth.uid() AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter usuários da fazenda
CREATE OR REPLACE FUNCTION get_farm_users(p_farm_id UUID)
RETURNS TABLE(
    user_id UUID,
    user_name TEXT,
    user_email TEXT,
    user_role TEXT,
    user_whatsapp TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP
) AS $$
BEGIN
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
    WHERE u.farm_id = p_farm_id
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter histórico de produção de leite
CREATE OR REPLACE FUNCTION get_milk_production_history(
    p_farm_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    production_id UUID,
    production_date DATE,
    quantity NUMERIC,
    quality_score NUMERIC,
    notes TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mp.id as production_id,
        DATE(mp.created_at) as production_date,
        mp.quantity,
        mp.quality_score,
        mp.notes,
        mp.created_at
    FROM milk_production mp
    WHERE mp.farm_id = p_farm_id
    AND (p_start_date IS NULL OR DATE(mp.created_at) >= p_start_date)
    AND (p_end_date IS NULL OR DATE(mp.created_at) <= p_end_date)
    ORDER BY mp.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter notificações do usuário
CREATE OR REPLACE FUNCTION get_user_notifications(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
    notification_id UUID,
    title TEXT,
    message TEXT,
    type TEXT,
    is_read BOOLEAN,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id as notification_id,
        n.title,
        n.message,
        n.type,
        n.is_read,
        n.created_at
    FROM notifications n
    WHERE n.user_id = p_user_id
    ORDER BY n.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para marcar notificação como lida
CREATE OR REPLACE FUNCTION mark_notification_read(p_notification_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE notifications 
    SET is_read = true, updated_at = NOW()
    WHERE id = p_notification_id AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter animais da fazenda
CREATE OR REPLACE FUNCTION get_farm_animals(p_farm_id UUID)
RETURNS TABLE(
    animal_id UUID,
    animal_name TEXT,
    animal_type TEXT,
    breed TEXT,
    birth_date DATE,
    weight NUMERIC,
    is_active BOOLEAN,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id as animal_id,
        a.name as animal_name,
        a.animal_type,
        a.breed,
        a.birth_date,
        a.weight,
        a.is_active,
        a.created_at
    FROM animals a
    WHERE a.farm_id = p_farm_id
    ORDER BY a.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter pagamentos da fazenda
CREATE OR REPLACE FUNCTION get_farm_payments(
    p_farm_id UUID,
    p_status TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    payment_id UUID,
    payment_type TEXT,
    amount NUMERIC,
    status TEXT,
    due_date DATE,
    description TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as payment_id,
        p.payment_type,
        p.amount,
        p.status,
        p.due_date,
        p.description,
        p.created_at
    FROM payments p
    WHERE p.farm_id = p_farm_id
    AND (p_status IS NULL OR p.status = p_status)
    ORDER BY p.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter tratamentos da fazenda
CREATE OR REPLACE FUNCTION get_farm_treatments(
    p_farm_id UUID,
    p_status TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    treatment_id UUID,
    animal_id UUID,
    treatment_type TEXT,
    status TEXT,
    start_date DATE,
    end_date DATE,
    medication TEXT,
    notes TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id as treatment_id,
        t.animal_id,
        t.treatment_type,
        t.status,
        t.start_date,
        t.end_date,
        t.medication,
        t.notes,
        t.created_at
    FROM treatments t
    JOIN animals a ON a.id = t.animal_id
    WHERE a.farm_id = p_farm_id
    AND (p_status IS NULL OR t.status = p_status)
    ORDER BY t.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'TODAS AS FUNÇÕES RPC FORAM CRIADAS COM SUCESSO!' as resultado; 