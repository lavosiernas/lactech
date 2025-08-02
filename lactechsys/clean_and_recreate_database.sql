-- =====================================================
-- SCRIPT DE LIMPEZA COMPLETA E RECRIAÇÃO DO BANCO
-- =====================================================

-- 1. REMOVER TODOS OS TRIGGERS PRIMEIRO
DROP TRIGGER IF EXISTS update_farms_updated_at ON farms;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_animals_updated_at ON animals;
DROP TRIGGER IF EXISTS update_milk_production_updated_at ON milk_production;
DROP TRIGGER IF EXISTS update_quality_tests_updated_at ON quality_tests;
DROP TRIGGER IF EXISTS update_animal_health_records_updated_at ON animal_health_records;
DROP TRIGGER IF EXISTS update_treatments_updated_at ON treatments;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP TRIGGER IF EXISTS update_user_access_requests_updated_at ON user_access_requests;
DROP TRIGGER IF EXISTS update_farm_settings_updated_at ON farm_settings;

-- 2. REMOVER TODAS AS FUNÇÕES RPC
DROP FUNCTION IF EXISTS check_farm_exists(TEXT, TEXT);
DROP FUNCTION IF EXISTS check_user_exists(TEXT);
DROP FUNCTION IF EXISTS create_initial_farm(TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, NUMERIC, NUMERIC, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS create_initial_user(UUID, UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS complete_farm_setup(UUID);
DROP FUNCTION IF EXISTS get_farm_statistics(UUID);
DROP FUNCTION IF EXISTS get_policies_for_table(TEXT);
DROP FUNCTION IF EXISTS is_farm_configured(UUID);
DROP FUNCTION IF EXISTS get_current_user_data();
DROP FUNCTION IF EXISTS get_farm_users(UUID);
DROP FUNCTION IF EXISTS get_milk_production_history(UUID, DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS get_user_notifications(UUID, INTEGER);
DROP FUNCTION IF EXISTS mark_notification_read(UUID);
DROP FUNCTION IF EXISTS get_farm_animals(UUID);
DROP FUNCTION IF EXISTS get_farm_payments(UUID, TEXT, INTEGER);
DROP FUNCTION IF EXISTS get_farm_treatments(UUID, TEXT, INTEGER);
DROP FUNCTION IF EXISTS get_production_stats(UUID, DATE, DATE);
DROP FUNCTION IF EXISTS cleanup_old_data(INTEGER);
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- 3. REMOVER TODOS OS ÍNDICES
DROP INDEX IF EXISTS idx_users_farm_id;
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_milk_production_farm_date;
DROP INDEX IF EXISTS idx_milk_production_user;
DROP INDEX IF EXISTS idx_animals_farm_id;
DROP INDEX IF EXISTS idx_treatments_farm_id;
DROP INDEX IF EXISTS idx_notifications_user_id;
DROP INDEX IF EXISTS idx_notifications_is_read;

-- 4. REMOVER TODAS AS TABELAS (EM ORDEM CORRETA)
DROP TABLE IF EXISTS secondary_accounts CASCADE;
DROP TABLE IF EXISTS user_access_requests CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS treatments CASCADE;
DROP TABLE IF EXISTS animal_health_records CASCADE;
DROP TABLE IF EXISTS quality_tests CASCADE;
DROP TABLE IF EXISTS milk_production CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS farm_settings CASCADE;
DROP TABLE IF EXISTS farms CASCADE;

-- 5. REMOVER EXTENSÕES (SE NECESSÁRIO)
-- DROP EXTENSION IF EXISTS "uuid-ossp";

-- 6. RECRIAR EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 7. RECRIAR TABELAS COM SCHEMA CORRETO
-- =====================================================

-- 1. FAZENDAS (COM TODAS AS COLUNAS)
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

-- 2. USUÁRIOS (COM TODAS AS COLUNAS)
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

-- 3. ANIMAIS
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

-- 4. PRODUÇÃO DE LEITE
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

-- 5. TESTES DE QUALIDADE
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

-- 6. REGISTROS DE SAÚDE ANIMAL
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

-- 7. TRATAMENTOS
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

-- 8. PAGAMENTOS
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

-- 9. NOTIFICAÇÕES
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

-- 10. SOLICITAÇÕES DE ACESSO
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

-- 11. CONFIGURAÇÕES DA FAZENDA
CREATE TABLE farm_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    setting_key VARCHAR(255) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(farm_id, setting_key)
);

-- 12. CONTAS SECUNDÁRIAS
CREATE TABLE secondary_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(primary_account_id, secondary_account_id)
);

-- 8. CRIAR ÍNDICES
CREATE INDEX idx_users_farm_id ON users(farm_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_milk_production_farm_date ON milk_production(farm_id, production_date);
CREATE INDEX idx_milk_production_user ON milk_production(user_id);
CREATE INDEX idx_animals_farm_id ON animals(farm_id);
CREATE INDEX idx_treatments_farm_id ON treatments(farm_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- 9. CRIAR FUNÇÃO DE ATUALIZAÇÃO
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10. CRIAR TRIGGERS
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

-- 11. ATIVAR RLS EM TODAS AS TABELAS
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

-- 12. CRIAR POLÍTICAS RLS BÁSICAS (PERMISSIVAS PARA TESTE)
CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true);
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

CREATE POLICY animals_select_policy ON animals FOR SELECT USING (true);
CREATE POLICY animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
CREATE POLICY animals_update_policy ON animals FOR UPDATE USING (true);
CREATE POLICY animals_delete_policy ON animals FOR DELETE USING (true);

CREATE POLICY milk_production_select_policy ON milk_production FOR SELECT USING (true);
CREATE POLICY milk_production_insert_policy ON milk_production FOR INSERT WITH CHECK (true);
CREATE POLICY milk_production_update_policy ON milk_production FOR UPDATE USING (true);
CREATE POLICY milk_production_delete_policy ON milk_production FOR DELETE USING (true);

CREATE POLICY quality_tests_select_policy ON quality_tests FOR SELECT USING (true);
CREATE POLICY quality_tests_insert_policy ON quality_tests FOR INSERT WITH CHECK (true);
CREATE POLICY quality_tests_update_policy ON quality_tests FOR UPDATE USING (true);
CREATE POLICY quality_tests_delete_policy ON quality_tests FOR DELETE USING (true);

CREATE POLICY animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
CREATE POLICY animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
CREATE POLICY animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true);
CREATE POLICY animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

CREATE POLICY treatments_select_policy ON treatments FOR SELECT USING (true);
CREATE POLICY treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
CREATE POLICY treatments_update_policy ON treatments FOR UPDATE USING (true);
CREATE POLICY treatments_delete_policy ON treatments FOR DELETE USING (true);

CREATE POLICY payments_select_policy ON payments FOR SELECT USING (true);
CREATE POLICY payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY payments_update_policy ON payments FOR UPDATE USING (true);
CREATE POLICY payments_delete_policy ON payments FOR DELETE USING (true);

CREATE POLICY notifications_select_policy ON notifications FOR SELECT USING (true);
CREATE POLICY notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY notifications_update_policy ON notifications FOR UPDATE USING (true);
CREATE POLICY notifications_delete_policy ON notifications FOR DELETE USING (true);

CREATE POLICY user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
CREATE POLICY user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
CREATE POLICY user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true);
CREATE POLICY user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

CREATE POLICY farm_settings_select_policy ON farm_settings FOR SELECT USING (true);
CREATE POLICY farm_settings_insert_policy ON farm_settings FOR INSERT WITH CHECK (true);
CREATE POLICY farm_settings_update_policy ON farm_settings FOR UPDATE USING (true);
CREATE POLICY farm_settings_delete_policy ON farm_settings FOR DELETE USING (true);

CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'BANCO DE DADOS LIMPO E RECRIADO COM SUCESSO!' as resultado; 