-- =====================================================
-- SISTEMA LACTECH - BANCO DE DADOS COMPLETO E PERFEITO
-- Script SQL para criar todo o sistema sem erros
-- =====================================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. TABELA DE FAZENDAS (COMPLETA)
-- =====================================================
CREATE TABLE farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255),
    cnpj VARCHAR(18),
    city VARCHAR(100),
    state VARCHAR(2),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    animal_count INTEGER DEFAULT 0,
    daily_production NUMERIC DEFAULT 0,
    total_area_hectares NUMERIC,
    setup_completed BOOLEAN DEFAULT false,
    is_configured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TABELA DE USUÁRIOS (COMPLETA)
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'funcionario',
    whatsapp VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    profile_photo_url TEXT,
    report_farm_name VARCHAR(255),
    report_farm_logo_base64 TEXT,
    report_footer_text TEXT,
    report_system_logo_base64 TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT users_email_farm_unique UNIQUE (email, farm_id)
);

-- =====================================================
-- 3. TABELA DE ANIMAIS (COMPLETA)
-- =====================================================
CREATE TABLE animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    name VARCHAR(255),
    identification VARCHAR(100),
    animal_type VARCHAR(50),
    breed VARCHAR(100),
    birth_date DATE,
    weight NUMERIC,
    health_status VARCHAR(50) DEFAULT 'healthy',
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. TABELA DE PRODUÇÃO DE LEITE (COMPLETA)
-- =====================================================
CREATE TABLE milk_production (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    production_date DATE NOT NULL,
    shift VARCHAR(20) DEFAULT 'manha',
    volume_liters NUMERIC NOT NULL,
    temperature NUMERIC,
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT milk_production_unique UNIQUE (farm_id, production_date, shift)
);

-- =====================================================
-- 5. TABELA DE TESTES DE QUALIDADE (COMPLETA)
-- =====================================================
CREATE TABLE quality_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    test_date DATE NOT NULL,
    fat_percentage NUMERIC,
    protein_percentage NUMERIC,
    somatic_cell_count INTEGER,
    total_bacterial_count INTEGER,
    quality_grade VARCHAR(10),
    bonus_percentage NUMERIC,
    laboratory VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT quality_tests_unique UNIQUE (farm_id, test_date)
);

-- =====================================================
-- 6. TABELA DE REGISTROS DE SAÚDE ANIMAL (COMPLETA)
-- =====================================================
CREATE TABLE animal_health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID REFERENCES animals(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    veterinarian_id UUID REFERENCES users(id) ON DELETE SET NULL,
    record_date DATE NOT NULL,
    diagnosis TEXT,
    symptoms TEXT,
    severity VARCHAR(50),
    status VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. TABELA DE TRATAMENTOS (COMPLETA)
-- =====================================================
CREATE TABLE treatments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    health_record_id UUID REFERENCES animal_health_records(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    veterinarian_id UUID REFERENCES users(id) ON DELETE SET NULL,
    medication_name VARCHAR(255),
    dosage VARCHAR(100),
    administration_route VARCHAR(100),
    treatment_start_date DATE,
    treatment_end_date DATE,
    withdrawal_period_days INTEGER,
    cost NUMERIC,
    notes TEXT,
    status VARCHAR(50),
    treatment_type VARCHAR(100),
    animal_id UUID REFERENCES animals(id) ON DELETE CASCADE,
    medication VARCHAR(255),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 8. TABELA DE PAGAMENTOS (COMPLETA)
-- =====================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    payment_date DATE,
    reference_period_start DATE,
    reference_period_end DATE,
    volume_liters NUMERIC,
    base_price_per_liter NUMERIC,
    quality_bonus NUMERIC,
    deductions NUMERIC,
    gross_amount NUMERIC,
    net_amount NUMERIC,
    payment_status VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 9. TABELA DE NOTIFICAÇÕES (COMPLETA)
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    message TEXT,
    type VARCHAR(50),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 10. TABELA DE SOLICITAÇÕES DE ACESSO (COMPLETA)
-- =====================================================
CREATE TABLE user_access_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    requester_name VARCHAR(255),
    requester_email VARCHAR(255),
    requester_phone VARCHAR(20),
    requested_role VARCHAR(50),
    message TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 11. TABELA DE CONFIGURAÇÕES DA FAZENDA (COMPLETA)
-- =====================================================
CREATE TABLE farm_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    setting_key VARCHAR(255) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(farm_id, setting_key)
);

-- =====================================================
-- 12. TABELA DE CONTAS SECUNDÁRIAS (COMPLETA)
-- =====================================================
CREATE TABLE secondary_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(primary_account_id, secondary_account_id)
);

-- =====================================================
-- ÍNDICES PARA OTIMIZAÇÃO
-- =====================================================
CREATE INDEX idx_users_farm_id ON users(farm_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_milk_production_farm_date ON milk_production(farm_id, production_date);
CREATE INDEX idx_milk_production_user ON milk_production(user_id);
CREATE INDEX idx_animals_farm_id ON animals(farm_id);
CREATE INDEX idx_treatments_farm_id ON treatments(farm_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_quality_tests_farm_date ON quality_tests(farm_id, test_date);
CREATE INDEX idx_payments_farm_status ON payments(farm_id, payment_status);
CREATE INDEX idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

-- =====================================================
-- FUNÇÃO DE ATUALIZAÇÃO AUTOMÁTICA
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS DE ATUALIZAÇÃO
-- =====================================================
CREATE TRIGGER update_farms_updated_at BEFORE UPDATE ON farms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_animals_updated_at BEFORE UPDATE ON animals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_milk_production_updated_at BEFORE UPDATE ON milk_production FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quality_tests_updated_at BEFORE UPDATE ON quality_tests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_animal_health_records_updated_at BEFORE UPDATE ON animal_health_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_treatments_updated_at BEFORE UPDATE ON treatments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_access_requests_updated_at BEFORE UPDATE ON user_access_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_farm_settings_updated_at BEFORE UPDATE ON farm_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ATIVAÇÃO DE RLS EM TODAS AS TABELAS
-- =====================================================
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE animal_health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_access_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS RLS BÁSICAS (PERMISSIVAS PARA TESTE)
-- =====================================================

-- Políticas para farms
CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true);
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

-- Políticas para users
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

-- Políticas para animals
CREATE POLICY animals_select_policy ON animals FOR SELECT USING (true);
CREATE POLICY animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
CREATE POLICY animals_update_policy ON animals FOR UPDATE USING (true);
CREATE POLICY animals_delete_policy ON animals FOR DELETE USING (true);

-- Políticas para milk_production
CREATE POLICY milk_production_select_policy ON milk_production FOR SELECT USING (true);
CREATE POLICY milk_production_insert_policy ON milk_production FOR INSERT WITH CHECK (true);
CREATE POLICY milk_production_update_policy ON milk_production FOR UPDATE USING (true);
CREATE POLICY milk_production_delete_policy ON milk_production FOR DELETE USING (true);

-- Políticas para quality_tests
CREATE POLICY quality_tests_select_policy ON quality_tests FOR SELECT USING (true);
CREATE POLICY quality_tests_insert_policy ON quality_tests FOR INSERT WITH CHECK (true);
CREATE POLICY quality_tests_update_policy ON quality_tests FOR UPDATE USING (true);
CREATE POLICY quality_tests_delete_policy ON quality_tests FOR DELETE USING (true);

-- Políticas para animal_health_records
CREATE POLICY animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
CREATE POLICY animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
CREATE POLICY animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true);
CREATE POLICY animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

-- Políticas para treatments
CREATE POLICY treatments_select_policy ON treatments FOR SELECT USING (true);
CREATE POLICY treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
CREATE POLICY treatments_update_policy ON treatments FOR UPDATE USING (true);
CREATE POLICY treatments_delete_policy ON treatments FOR DELETE USING (true);

-- Políticas para payments
CREATE POLICY payments_select_policy ON payments FOR SELECT USING (true);
CREATE POLICY payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY payments_update_policy ON payments FOR UPDATE USING (true);
CREATE POLICY payments_delete_policy ON payments FOR DELETE USING (true);

-- Políticas para notifications
CREATE POLICY notifications_select_policy ON notifications FOR SELECT USING (true);
CREATE POLICY notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY notifications_update_policy ON notifications FOR UPDATE USING (true);
CREATE POLICY notifications_delete_policy ON notifications FOR DELETE USING (true);

-- Políticas para user_access_requests
CREATE POLICY user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
CREATE POLICY user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
CREATE POLICY user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true);
CREATE POLICY user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

-- Políticas para farm_settings
CREATE POLICY farm_settings_select_policy ON farm_settings FOR SELECT USING (true);
CREATE POLICY farm_settings_insert_policy ON farm_settings FOR INSERT WITH CHECK (true);
CREATE POLICY farm_settings_update_policy ON farm_settings FOR UPDATE USING (true);
CREATE POLICY farm_settings_delete_policy ON farm_settings FOR DELETE USING (true);

-- Políticas para secondary_accounts
CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- =====================================================
-- FUNÇÕES RPC ESSENCIAIS PARA O SISTEMA
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
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) = CURRENT_DATE THEN mp.volume_liters ELSE 0 END), 0) as total_production_today,
        COALESCE(SUM(CASE WHEN DATE(mp.created_at) >= DATE_TRUNC('month', CURRENT_DATE) THEN mp.volume_liters ELSE 0 END), 0) as total_production_month,
        COALESCE(COUNT(u.id), 0)::INTEGER as active_users,
        COALESCE(COUNT(p.id), 0)::INTEGER as pending_payments
    FROM farms f
    LEFT JOIN animals a ON a.farm_id = f.id AND a.is_active = true
    LEFT JOIN milk_production mp ON mp.farm_id = f.id
    LEFT JOIN users u ON u.farm_id = f.id AND u.is_active = true
    LEFT JOIN payments p ON p.farm_id = f.id AND p.payment_status = 'pending'
    WHERE f.id = p_farm_id
    GROUP BY f.id;
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
    volume_liters NUMERIC,
    shift VARCHAR(20),
    temperature NUMERIC,
    observations TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mp.id as production_id,
        mp.production_date,
        mp.volume_liters,
        mp.shift,
        mp.temperature,
        mp.observations,
        mp.created_at
    FROM milk_production mp
    WHERE mp.farm_id = p_farm_id
    AND (p_start_date IS NULL OR mp.production_date >= p_start_date)
    AND (p_end_date IS NULL OR mp.production_date <= p_end_date)
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
    payment_date DATE,
    volume_liters NUMERIC,
    gross_amount NUMERIC,
    net_amount NUMERIC,
    payment_status TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
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
    WHERE p.farm_id = p_farm_id
    AND (p_status IS NULL OR p.payment_status = p_status)
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
SELECT 'SISTEMA LACTECH CRIADO COM SUCESSO! Todas as tabelas, funções e políticas foram configuradas.' as resultado; 