-- =====================================================
-- CORREÇÃO COMPLETA DE TODAS AS TABELAS E CONSULTAS
-- =====================================================

-- 1. VERIFICAR TABELAS QUE EXISTEM
SELECT 'TABELAS EXISTENTES:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 2. CRIAR TABELA FINANCIAL_RECORDS SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS financial_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. ADICIONAR COLUNAS QUE FALTAM NA TABELA USERS
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_logo_base64 TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_footer_text TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_system_logo_base64 TEXT;

-- 4. ADICIONAR COLUNAS QUE FALTAM NA TABELA FARMS
ALTER TABLE farms ADD COLUMN IF NOT EXISTS cnpj TEXT;
ALTER TABLE farms ADD COLUMN IF NOT EXISTS city TEXT DEFAULT 'Cidade';
ALTER TABLE farms ADD COLUMN IF NOT EXISTS state TEXT DEFAULT 'MG';
ALTER TABLE farms ADD COLUMN IF NOT EXISTS animal_count INTEGER DEFAULT 0;

-- 5. VERIFICAR E CRIAR TABELA SECONDARY_ACCOUNTS
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    primary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(primary_account_id, secondary_account_id)
);

-- 6. ATIVAR RLS EM TODAS AS TABELAS PRINCIPAIS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
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
ALTER TABLE financial_records ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICAS PERMISSIVAS PARA TODAS AS TABELAS
-- Users
DROP POLICY IF EXISTS users_select_policy ON users;
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
DROP POLICY IF EXISTS users_insert_policy ON users;
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS users_update_policy ON users;
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
DROP POLICY IF EXISTS users_delete_policy ON users;
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

-- Farms
DROP POLICY IF EXISTS farms_select_policy ON farms;
CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
DROP POLICY IF EXISTS farms_insert_policy ON farms;
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS farms_update_policy ON farms;
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true);
DROP POLICY IF EXISTS farms_delete_policy ON farms;
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

-- Animals
DROP POLICY IF EXISTS animals_select_policy ON animals;
CREATE POLICY animals_select_policy ON animals FOR SELECT USING (true);
DROP POLICY IF EXISTS animals_insert_policy ON animals;
CREATE POLICY animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS animals_update_policy ON animals;
CREATE POLICY animals_update_policy ON animals FOR UPDATE USING (true);
DROP POLICY IF EXISTS animals_delete_policy ON animals;
CREATE POLICY animals_delete_policy ON animals FOR DELETE USING (true);

-- Milk Production
DROP POLICY IF EXISTS milk_production_select_policy ON milk_production;
CREATE POLICY milk_production_select_policy ON milk_production FOR SELECT USING (true);
DROP POLICY IF EXISTS milk_production_insert_policy ON milk_production;
CREATE POLICY milk_production_insert_policy ON milk_production FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS milk_production_update_policy ON milk_production;
CREATE POLICY milk_production_update_policy ON milk_production FOR UPDATE USING (true);
DROP POLICY IF EXISTS milk_production_delete_policy ON milk_production;
CREATE POLICY milk_production_delete_policy ON milk_production FOR DELETE USING (true);

-- Quality Tests
DROP POLICY IF EXISTS quality_tests_select_policy ON quality_tests;
CREATE POLICY quality_tests_select_policy ON quality_tests FOR SELECT USING (true);
DROP POLICY IF EXISTS quality_tests_insert_policy ON quality_tests;
CREATE POLICY quality_tests_insert_policy ON quality_tests FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS quality_tests_update_policy ON quality_tests;
CREATE POLICY quality_tests_update_policy ON quality_tests FOR UPDATE USING (true);
DROP POLICY IF EXISTS quality_tests_delete_policy ON quality_tests;
CREATE POLICY quality_tests_delete_policy ON quality_tests FOR DELETE USING (true);

-- Animal Health Records
DROP POLICY IF EXISTS animal_health_records_select_policy ON animal_health_records;
CREATE POLICY animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
DROP POLICY IF EXISTS animal_health_records_insert_policy ON animal_health_records;
CREATE POLICY animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS animal_health_records_update_policy ON animal_health_records;
CREATE POLICY animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true);
DROP POLICY IF EXISTS animal_health_records_delete_policy ON animal_health_records;
CREATE POLICY animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

-- Treatments
DROP POLICY IF EXISTS treatments_select_policy ON treatments;
CREATE POLICY treatments_select_policy ON treatments FOR SELECT USING (true);
DROP POLICY IF EXISTS treatments_insert_policy ON treatments;
CREATE POLICY treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS treatments_update_policy ON treatments;
CREATE POLICY treatments_update_policy ON treatments FOR UPDATE USING (true);
DROP POLICY IF EXISTS treatments_delete_policy ON treatments;
CREATE POLICY treatments_delete_policy ON treatments FOR DELETE USING (true);

-- Payments
DROP POLICY IF EXISTS payments_select_policy ON payments;
CREATE POLICY payments_select_policy ON payments FOR SELECT USING (true);
DROP POLICY IF EXISTS payments_insert_policy ON payments;
CREATE POLICY payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS payments_update_policy ON payments;
CREATE POLICY payments_update_policy ON payments FOR UPDATE USING (true);
DROP POLICY IF EXISTS payments_delete_policy ON payments;
CREATE POLICY payments_delete_policy ON payments FOR DELETE USING (true);

-- Notifications
DROP POLICY IF EXISTS notifications_select_policy ON notifications;
CREATE POLICY notifications_select_policy ON notifications FOR SELECT USING (true);
DROP POLICY IF EXISTS notifications_insert_policy ON notifications;
CREATE POLICY notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS notifications_update_policy ON notifications;
CREATE POLICY notifications_update_policy ON notifications FOR UPDATE USING (true);
DROP POLICY IF EXISTS notifications_delete_policy ON notifications;
CREATE POLICY notifications_delete_policy ON notifications FOR DELETE USING (true);

-- User Access Requests
DROP POLICY IF EXISTS user_access_requests_select_policy ON user_access_requests;
CREATE POLICY user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
DROP POLICY IF EXISTS user_access_requests_insert_policy ON user_access_requests;
CREATE POLICY user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS user_access_requests_update_policy ON user_access_requests;
CREATE POLICY user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true);
DROP POLICY IF EXISTS user_access_requests_delete_policy ON user_access_requests;
CREATE POLICY user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

-- Farm Settings
DROP POLICY IF EXISTS farm_settings_select_policy ON farm_settings;
CREATE POLICY farm_settings_select_policy ON farm_settings FOR SELECT USING (true);
DROP POLICY IF EXISTS farm_settings_insert_policy ON farm_settings;
CREATE POLICY farm_settings_insert_policy ON farm_settings FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS farm_settings_update_policy ON farm_settings;
CREATE POLICY farm_settings_update_policy ON farm_settings FOR UPDATE USING (true);
DROP POLICY IF EXISTS farm_settings_delete_policy ON farm_settings;
CREATE POLICY farm_settings_delete_policy ON farm_settings FOR DELETE USING (true);

-- Secondary Accounts
DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- Financial Records
DROP POLICY IF EXISTS financial_records_select_policy ON financial_records;
CREATE POLICY financial_records_select_policy ON financial_records FOR SELECT USING (true);
DROP POLICY IF EXISTS financial_records_insert_policy ON financial_records;
CREATE POLICY financial_records_insert_policy ON financial_records FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS financial_records_update_policy ON financial_records;
CREATE POLICY financial_records_update_policy ON financial_records FOR UPDATE USING (true);
DROP POLICY IF EXISTS financial_records_delete_policy ON financial_records;
CREATE POLICY financial_records_delete_policy ON financial_records FOR DELETE USING (true);

-- 8. CRIAR FUNÇÃO GET_USER_PROFILE CORRIGIDA
DROP FUNCTION IF EXISTS get_user_profile();

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

-- 9. VERIFICAR ESTRUTURA FINAL
SELECT 'ESTRUTURA FINAL DA TABELA USERS:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

SELECT 'ESTRUTURA FINAL DA TABELA FARMS:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'farms' 
ORDER BY ordinal_position;

-- 10. MENSAGEM FINAL
SELECT 'SISTEMA COMPLETAMENTE CORRIGIDO! Todas as tabelas, colunas e políticas foram configuradas.' as resultado; 