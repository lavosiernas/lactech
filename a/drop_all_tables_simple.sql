-- =====================================================
-- SCRIPT SIMPLES PARA LIMPAR O BANCO
-- Remove apenas o que existe
-- =====================================================

-- 1. REMOVER TODAS AS FUNÇÕES (COM CASCADE - remove dependências automaticamente)
DROP FUNCTION IF EXISTS check_farm_exists CASCADE;
DROP FUNCTION IF EXISTS check_user_exists CASCADE;
DROP FUNCTION IF EXISTS create_initial_farm CASCADE;
DROP FUNCTION IF EXISTS create_initial_user CASCADE;
DROP FUNCTION IF EXISTS complete_farm_setup CASCADE;
DROP FUNCTION IF EXISTS get_farm_statistics CASCADE;
DROP FUNCTION IF EXISTS get_policies_for_table CASCADE;
DROP FUNCTION IF EXISTS is_farm_configured CASCADE;
DROP FUNCTION IF EXISTS get_current_user_data CASCADE;
DROP FUNCTION IF EXISTS get_farm_users CASCADE;
DROP FUNCTION IF EXISTS get_milk_production_history CASCADE;
DROP FUNCTION IF EXISTS get_user_notifications CASCADE;
DROP FUNCTION IF EXISTS mark_notification_read CASCADE;
DROP FUNCTION IF EXISTS get_farm_animals CASCADE;
DROP FUNCTION IF EXISTS get_farm_payments CASCADE;
DROP FUNCTION IF EXISTS get_farm_treatments CASCADE;
DROP FUNCTION IF EXISTS get_production_stats CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_data CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- 2. REMOVER TODAS AS TABELAS (COM CASCADE - remove dependências automaticamente)
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

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'BANCO LIMPO! Agora execute o clean_and_recreate_database.sql' as resultado; 