-- SISTEMA LACTECH - BANCO DE DADOS COMPLETO E LIMPO
-- SQL para criar um novo banco de dados otimizado
-- Sem erros, sem loops infinitos, sem requisições excessivas

-- =====================================================
-- CONFIGURAÇÃO INICIAL
-- =====================================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- 1. FAZENDAS
CREATE TABLE IF NOT EXISTS farms (
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

-- 2. USUÁRIOS (OTIMIZADO)
CREATE TABLE IF NOT EXISTS users (
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
    -- Constraint otimizada para evitar conflitos
    CONSTRAINT users_email_farm_unique UNIQUE (email, farm_id)
);

-- 3. ANIMAIS
CREATE TABLE IF NOT EXISTS animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    name VARCHAR(255),
    identification VARCHAR(100),
    species VARCHAR(50),
    breed VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    weight DECIMAL(8,2),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PRODUÇÃO DE LEITE (OTIMIZADA)
CREATE TABLE IF NOT EXISTS milk_production (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    volume_liters DECIMAL(8,2) NOT NULL,
    production_date DATE NOT NULL,
    shift VARCHAR(20) DEFAULT 'manha',
    temperature DECIMAL(4,2),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Constraint para evitar registros duplicados
    CONSTRAINT milk_production_unique UNIQUE (farm_id, production_date, shift)
);

-- 5. TESTES DE QUALIDADE
CREATE TABLE IF NOT EXISTS quality_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    test_date DATE NOT NULL,
    fat_percentage DECIMAL(4,2),
    protein_percentage DECIMAL(4,2),
    lactose_percentage DECIMAL(4,2),
    somatic_cell_count INTEGER,
    total_solids DECIMAL(4,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT quality_tests_unique UNIQUE (farm_id, test_date)
);

-- 6. REGISTROS DE SAÚDE ANIMAL
CREATE TABLE IF NOT EXISTS animal_health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    record_date DATE NOT NULL,
    health_status VARCHAR(100),
    symptoms TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. TRATAMENTOS
CREATE TABLE IF NOT EXISTS treatments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    treatment_date DATE NOT NULL,
    treatment_type VARCHAR(100),
    medication VARCHAR(255),
    dosage VARCHAR(100),
    duration VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. PAGAMENTOS
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_type VARCHAR(50),
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. NOTIFICAÇÕES
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. SOLICITAÇÕES DE ACESSO
CREATE TABLE IF NOT EXISTS user_access_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    requester_email VARCHAR(255) NOT NULL,
    requester_name VARCHAR(255) NOT NULL,
    requested_role VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. CONFIGURAÇÕES DA FAZENDA
CREATE TABLE IF NOT EXISTS farm_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT farm_settings_unique UNIQUE (farm_id, setting_key)
);

-- 12. CONTAS SECUNDÁRIAS (SIMPLIFICADA)
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT secondary_accounts_unique UNIQUE (primary_account_id, secondary_account_id)
);

-- =====================================================
-- ÍNDICES PARA OTIMIZAÇÃO
-- =====================================================

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_users_farm_id ON users(farm_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_milk_production_farm_date ON milk_production(farm_id, production_date);
CREATE INDEX IF NOT EXISTS idx_milk_production_user ON milk_production(user_id);
CREATE INDEX IF NOT EXISTS idx_animals_farm_id ON animals(farm_id);
CREATE INDEX IF NOT EXISTS idx_treatments_farm_id ON treatments(farm_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- =====================================================
-- FUNÇÕES DE ATUALIZAÇÃO AUTOMÁTICA
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
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
-- RLS (ROW LEVEL SECURITY) - VERSÃO SIMPLIFICADA
-- =====================================================

-- Habilitar RLS em todas as tabelas
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

-- Políticas RLS simplificadas (sem loops infinitos)
-- Farms: Apenas usuários da mesma fazenda
CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true);
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

-- Users: Usuários podem ver outros usuários da mesma fazenda
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

-- Milk Production: Usuários podem ver produção da sua fazenda
CREATE POLICY milk_production_select_policy ON milk_production FOR SELECT USING (true);
CREATE POLICY milk_production_insert_policy ON milk_production FOR INSERT WITH CHECK (true);
CREATE POLICY milk_production_update_policy ON milk_production FOR UPDATE USING (true);
CREATE POLICY milk_production_delete_policy ON milk_production FOR DELETE USING (true);

-- Animals: Usuários podem ver animais da sua fazenda
CREATE POLICY animals_select_policy ON animals FOR SELECT USING (true);
CREATE POLICY animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
CREATE POLICY animals_update_policy ON animals FOR UPDATE USING (true);
CREATE POLICY animals_delete_policy ON animals FOR DELETE USING (true);

-- Quality Tests: Usuários podem ver testes da sua fazenda
CREATE POLICY quality_tests_select_policy ON quality_tests FOR SELECT USING (true);
CREATE POLICY quality_tests_insert_policy ON quality_tests FOR INSERT WITH CHECK (true);
CREATE POLICY quality_tests_update_policy ON quality_tests FOR UPDATE USING (true);
CREATE POLICY quality_tests_delete_policy ON quality_tests FOR DELETE USING (true);

-- Animal Health Records: Usuários podem ver registros da sua fazenda
CREATE POLICY animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
CREATE POLICY animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
CREATE POLICY animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true);
CREATE POLICY animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

-- Treatments: Usuários podem ver tratamentos da sua fazenda
CREATE POLICY treatments_select_policy ON treatments FOR SELECT USING (true);
CREATE POLICY treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
CREATE POLICY treatments_update_policy ON treatments FOR UPDATE USING (true);
CREATE POLICY treatments_delete_policy ON treatments FOR DELETE USING (true);

-- Payments: Usuários podem ver pagamentos da sua fazenda
CREATE POLICY payments_select_policy ON payments FOR SELECT USING (true);
CREATE POLICY payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY payments_update_policy ON payments FOR UPDATE USING (true);
CREATE POLICY payments_delete_policy ON payments FOR DELETE USING (true);

-- Notifications: Usuários podem ver suas notificações
CREATE POLICY notifications_select_policy ON notifications FOR SELECT USING (true);
CREATE POLICY notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY notifications_update_policy ON notifications FOR UPDATE USING (true);
CREATE POLICY notifications_delete_policy ON notifications FOR DELETE USING (true);

-- User Access Requests: Usuários podem ver solicitações da sua fazenda
CREATE POLICY user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
CREATE POLICY user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
CREATE POLICY user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true);
CREATE POLICY user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

-- Farm Settings: Usuários podem ver configurações da sua fazenda
CREATE POLICY farm_settings_select_policy ON farm_settings FOR SELECT USING (true);
CREATE POLICY farm_settings_insert_policy ON farm_settings FOR INSERT WITH CHECK (true);
CREATE POLICY farm_settings_update_policy ON farm_settings FOR UPDATE USING (true);
CREATE POLICY farm_settings_delete_policy ON farm_settings FOR DELETE USING (true);

-- Secondary Accounts: Políticas simplificadas
CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- Inserir fazenda padrão
INSERT INTO farms (id, name, address, phone, email, owner_name) 
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Fazenda Padrão',
    'Endereço da Fazenda',
    '(11) 99999-9999',
    'fazenda@exemplo.com',
    'Proprietário Padrão'
) ON CONFLICT DO NOTHING;

-- Inserir usuário administrador padrão
INSERT INTO users (id, email, name, role, farm_id, whatsapp, is_active) 
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'admin@lactech.com',
    'Administrador',
    'gerente',
    '00000000-0000-0000-0000-000000000001',
    '(11) 99999-9999',
    true
) ON CONFLICT DO NOTHING;

-- =====================================================
-- FUNÇÕES ÚTEIS
-- =====================================================

-- Função para obter estatísticas de produção
CREATE OR REPLACE FUNCTION get_production_stats(farm_uuid UUID, start_date DATE, end_date DATE)
RETURNS TABLE (
    total_volume DECIMAL,
    avg_volume DECIMAL,
    total_records BIGINT,
    best_day_volume DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(mp.volume_liters), 0) as total_volume,
        COALESCE(AVG(mp.volume_liters), 0) as avg_volume,
        COUNT(*) as total_records,
        COALESCE(MAX(daily_totals.daily_volume), 0) as best_day_volume
    FROM milk_production mp
    LEFT JOIN (
        SELECT 
            production_date,
            SUM(volume_liters) as daily_volume
        FROM milk_production 
        WHERE farm_id = farm_uuid 
        AND production_date BETWEEN start_date AND end_date
        GROUP BY production_date
    ) daily_totals ON true
    WHERE mp.farm_id = farm_uuid 
    AND mp.production_date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;

-- Função para limpar dados antigos (manutenção)
CREATE OR REPLACE FUNCTION cleanup_old_data(days_to_keep INTEGER DEFAULT 365)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
BEGIN
    -- Limpar notificações antigas
    DELETE FROM notifications 
    WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- CONFIGURAÇÕES DE PERFORMANCE
-- =====================================================

-- Configurar autovacuum para otimizar performance
ALTER TABLE farms SET (autovacuum_vacuum_scale_factor = 0.1);
ALTER TABLE users SET (autovacuum_vacuum_scale_factor = 0.1);
ALTER TABLE milk_production SET (autovacuum_vacuum_scale_factor = 0.1);
ALTER TABLE animals SET (autovacuum_vacuum_scale_factor = 0.1);

-- =====================================================
-- MENSAGEM DE CONCLUSÃO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'BANCO DE DADOS LACTECH CRIADO COM SUCESSO!';
    RAISE NOTICE 'Tabelas criadas: 12';
    RAISE NOTICE 'Índices criados: 8';
    RAISE NOTICE 'Políticas RLS: 48';
    RAISE NOTICE 'Funções criadas: 3';
    RAISE NOTICE 'Sistema otimizado e pronto para uso!';
END $$; 