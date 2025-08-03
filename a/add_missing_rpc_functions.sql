-- =====================================================
-- ADICIONAR FUNÇÕES RPC QUE ESTÃO FALTANDO
-- =====================================================

-- Função get_user_profile
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

-- Função create_initial_farm
CREATE OR REPLACE FUNCTION create_initial_farm(
    p_name TEXT,
    p_owner_name TEXT DEFAULT 'Proprietário',
    p_city TEXT DEFAULT 'Cidade',
    p_state TEXT DEFAULT 'MG'
)
RETURNS UUID AS $$
DECLARE
    farm_id UUID;
BEGIN
    INSERT INTO farms (name, owner_name, city, state)
    VALUES (p_name, p_owner_name, p_city, p_state)
    RETURNING id INTO farm_id;
    
    RETURN farm_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função create_initial_user
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
    INSERT INTO users (id, farm_id, name, email, role, whatsapp)
    VALUES (p_user_id, p_farm_id, p_name, p_email, p_role, p_whatsapp);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função check_farm_exists
CREATE OR REPLACE FUNCTION check_farm_exists(
    p_cnpj TEXT,
    p_name TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM farms 
        WHERE cnpj = p_cnpj OR name = p_name
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_farm_statistics
CREATE OR REPLACE FUNCTION get_farm_statistics(
    p_farm_id UUID
)
RETURNS TABLE(
    total_animals INTEGER,
    total_milk_production NUMERIC,
    active_treatments INTEGER,
    total_payments NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(COUNT(a.id), 0) as total_animals,
        COALESCE(SUM(mp.quantity), 0) as total_milk_production,
        COALESCE(COUNT(t.id), 0) as active_treatments,
        COALESCE(SUM(p.amount), 0) as total_payments
    FROM farms f
    LEFT JOIN animals a ON a.farm_id = f.id
    LEFT JOIN milk_production mp ON mp.animal_id = a.id
    LEFT JOIN treatments t ON t.animal_id = a.id AND t.status = 'active'
    LEFT JOIN payments p ON p.farm_id = f.id
    WHERE f.id = p_farm_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_user_by_email
CREATE OR REPLACE FUNCTION get_user_by_email(
    p_email TEXT
)
RETURNS TABLE(
    id UUID,
    farm_id UUID,
    name TEXT,
    email TEXT,
    role TEXT,
    whatsapp TEXT,
    is_active BOOLEAN,
    profile_photo_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.farm_id,
        u.name,
        u.email,
        u.role,
        u.whatsapp,
        u.is_active,
        u.profile_photo_url
    FROM users u
    WHERE u.email = p_email AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função update_user_profile
CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id UUID,
    p_name TEXT,
    p_whatsapp TEXT,
    p_profile_photo_url TEXT
)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET 
        name = p_name,
        whatsapp = p_whatsapp,
        profile_photo_url = p_profile_photo_url,
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função change_user_password
CREATE OR REPLACE FUNCTION change_user_password(
    p_user_id UUID,
    p_new_password TEXT
)
RETURNS VOID AS $$
BEGIN
    -- Esta função seria chamada pelo frontend para alterar senha via Supabase Auth
    -- Por enquanto, apenas registra a tentativa
    INSERT INTO user_access_requests (user_id, request_type, status)
    VALUES (p_user_id, 'password_change', 'pending');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_farm_users
CREATE OR REPLACE FUNCTION get_farm_users(
    p_farm_id UUID
)
RETURNS TABLE(
    id UUID,
    name TEXT,
    email TEXT,
    role TEXT,
    whatsapp TEXT,
    is_active BOOLEAN,
    profile_photo_url TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name,
        u.email,
        u.role,
        u.whatsapp,
        u.is_active,
        u.profile_photo_url,
        u.created_at
    FROM users u
    WHERE u.farm_id = p_farm_id AND u.is_active = true
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_animal_statistics
CREATE OR REPLACE FUNCTION get_animal_statistics(
    p_farm_id UUID
)
RETURNS TABLE(
    total_animals INTEGER,
    active_animals INTEGER,
    lactating_cows INTEGER,
    dry_cows INTEGER,
    calves INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(a.id) as total_animals,
        COUNT(CASE WHEN a.status = 'active' THEN 1 END) as active_animals,
        COUNT(CASE WHEN a.status = 'lactating' THEN 1 END) as lactating_cows,
        COUNT(CASE WHEN a.status = 'dry' THEN 1 END) as dry_cows,
        COUNT(CASE WHEN a.status = 'calf' THEN 1 END) as calves
    FROM animals a
    WHERE a.farm_id = p_farm_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_milk_production_stats
CREATE OR REPLACE FUNCTION get_milk_production_stats(
    p_farm_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    total_quantity NUMERIC,
    average_quantity NUMERIC,
    production_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM(mp.quantity) as total_quantity,
        AVG(mp.quantity) as average_quantity,
        mp.production_date
    FROM milk_production mp
    JOIN animals a ON a.id = mp.animal_id
    WHERE a.farm_id = p_farm_id 
    AND mp.production_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    GROUP BY mp.production_date
    ORDER BY mp.production_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_quality_tests_stats
CREATE OR REPLACE FUNCTION get_quality_tests_stats(
    p_farm_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    total_tests INTEGER,
    average_fat_content NUMERIC,
    average_protein_content NUMERIC,
    test_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(qt.id) as total_tests,
        AVG(qt.fat_content) as average_fat_content,
        AVG(qt.protein_content) as average_protein_content,
        qt.test_date
    FROM quality_tests qt
    JOIN animals a ON a.id = qt.animal_id
    WHERE a.farm_id = p_farm_id 
    AND qt.test_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    GROUP BY qt.test_date
    ORDER BY qt.test_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_health_records_stats
CREATE OR REPLACE FUNCTION get_health_records_stats(
    p_farm_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    total_records INTEGER,
    healthy_animals INTEGER,
    sick_animals INTEGER,
    record_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(ahr.id) as total_records,
        COUNT(CASE WHEN ahr.health_status = 'healthy' THEN 1 END) as healthy_animals,
        COUNT(CASE WHEN ahr.health_status = 'sick' THEN 1 END) as sick_animals,
        ahr.record_date
    FROM animal_health_records ahr
    JOIN animals a ON a.id = ahr.animal_id
    WHERE a.farm_id = p_farm_id 
    AND ahr.record_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    GROUP BY ahr.record_date
    ORDER BY ahr.record_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_treatments_stats
CREATE OR REPLACE FUNCTION get_treatments_stats(
    p_farm_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    total_treatments INTEGER,
    active_treatments INTEGER,
    completed_treatments INTEGER,
    treatment_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(t.id) as total_treatments,
        COUNT(CASE WHEN t.status = 'active' THEN 1 END) as active_treatments,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_treatments,
        t.start_date::DATE as treatment_date
    FROM treatments t
    JOIN animals a ON a.id = t.animal_id
    WHERE a.farm_id = p_farm_id 
    AND t.start_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    GROUP BY t.start_date::DATE
    ORDER BY t.start_date::DATE DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função get_payments_stats
CREATE OR REPLACE FUNCTION get_payments_stats(
    p_farm_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE(
    total_payments INTEGER,
    total_amount NUMERIC,
    average_amount NUMERIC,
    payment_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(p.id) as total_payments,
        SUM(p.amount) as total_amount,
        AVG(p.amount) as average_amount,
        p.payment_date
    FROM payments p
    WHERE p.farm_id = p_farm_id 
    AND p.payment_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    GROUP BY p.payment_date
    ORDER BY p.payment_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'FUNÇÕES RPC ADICIONADAS COM SUCESSO! Todas as funções necessárias foram criadas.' as resultado; 