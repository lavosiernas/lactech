-- =====================================================
-- SCRIPT PARA REMOVER TUDO DO BANCO
-- Execute este script PRIMEIRO para limpar tudo
-- =====================================================

-- 1. REMOVER TODOS OS TRIGGERS
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

-- 2. REMOVER TODAS AS FUNÇÕES (COM CASCADE)
DROP FUNCTION IF EXISTS check_farm_exists(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS check_user_exists(TEXT) CASCADE;
DROP FUNCTION IF EXISTS create_initial_farm(TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, NUMERIC, NUMERIC, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS create_initial_user(UUID, UUID, TEXT, TEXT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS complete_farm_setup(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_farm_statistics(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_policies_for_table(TEXT) CASCADE;
DROP FUNCTION IF EXISTS is_farm_configured(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_current_user_data() CASCADE;
DROP FUNCTION IF EXISTS get_farm_users(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_milk_production_history(UUID, DATE, DATE, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_user_notifications(UUID, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS mark_notification_read(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_farm_animals(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_farm_payments(UUID, TEXT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_farm_treatments(UUID, TEXT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_production_stats(UUID, DATE, DATE) CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_data(INTEGER) CASCADE;
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

-- 5. REMOVER POLÍTICAS RLS (SE EXISTIREM)
DROP POLICY IF EXISTS farms_select_policy ON farms;
DROP POLICY IF EXISTS farms_insert_policy ON farms;
DROP POLICY IF EXISTS farms_update_policy ON farms;
DROP POLICY IF EXISTS farms_delete_policy ON farms;

DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS animals_select_policy ON animals;
DROP POLICY IF EXISTS animals_insert_policy ON animals;
DROP POLICY IF EXISTS animals_update_policy ON animals;
DROP POLICY IF EXISTS animals_delete_policy ON animals;

DROP POLICY IF EXISTS milk_production_select_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_insert_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_update_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_delete_policy ON milk_production;

DROP POLICY IF EXISTS quality_tests_select_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_insert_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_update_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_delete_policy ON quality_tests;

DROP POLICY IF EXISTS animal_health_records_select_policy ON animal_health_records;
DROP POLICY IF EXISTS animal_health_records_insert_policy ON animal_health_records;
DROP POLICY IF EXISTS animal_health_records_update_policy ON animal_health_records;
DROP POLICY IF EXISTS animal_health_records_delete_policy ON animal_health_records;

DROP POLICY IF EXISTS treatments_select_policy ON treatments;
DROP POLICY IF EXISTS treatments_insert_policy ON treatments;
DROP POLICY IF EXISTS treatments_update_policy ON treatments;
DROP POLICY IF EXISTS treatments_delete_policy ON treatments;

DROP POLICY IF EXISTS payments_select_policy ON payments;
DROP POLICY IF EXISTS payments_insert_policy ON payments;
DROP POLICY IF EXISTS payments_update_policy ON payments;
DROP POLICY IF EXISTS payments_delete_policy ON payments;

DROP POLICY IF EXISTS notifications_select_policy ON notifications;
DROP POLICY IF EXISTS notifications_insert_policy ON notifications;
DROP POLICY IF EXISTS notifications_update_policy ON notifications;
DROP POLICY IF EXISTS notifications_delete_policy ON notifications;

DROP POLICY IF EXISTS user_access_requests_select_policy ON user_access_requests;
DROP POLICY IF EXISTS user_access_requests_insert_policy ON user_access_requests;
DROP POLICY IF EXISTS user_access_requests_update_policy ON user_access_requests;
DROP POLICY IF EXISTS user_access_requests_delete_policy ON user_access_requests;

DROP POLICY IF EXISTS farm_settings_select_policy ON farm_settings;
DROP POLICY IF EXISTS farm_settings_insert_policy ON farm_settings;
DROP POLICY IF EXISTS farm_settings_update_policy ON farm_settings;
DROP POLICY IF EXISTS farm_settings_delete_policy ON farm_settings;

DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'TODAS AS TABELAS, FUNÇÕES E POLÍTICAS FORAM REMOVIDAS!' as resultado; 