-- =====================================================
-- REVERTER TODAS AS ALTERAÇÕES DO BANCO (VERSÃO SEGURA)
-- =====================================================

-- 1. DESABILITAR RLS EM TODAS AS TABELAS (APENAS SE EXISTIREM)
DO $$ 
BEGIN
    -- Verificar e desabilitar RLS apenas nas tabelas que existem
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
        ALTER TABLE users DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'farms') THEN
        ALTER TABLE farms DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'animals') THEN
        ALTER TABLE animals DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'milk_production') THEN
        ALTER TABLE milk_production DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'quality_tests') THEN
        ALTER TABLE quality_tests DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'animal_health_records') THEN
        ALTER TABLE animal_health_records DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'treatments') THEN
        ALTER TABLE treatments DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
        ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_access_requests') THEN
        ALTER TABLE user_access_requests DISABLE ROW LEVEL SECURITY;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'secondary_accounts') THEN
        ALTER TABLE secondary_accounts DISABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- 2. REMOVER TODAS AS POLÍTICAS RLS (APENAS SE EXISTIREM)
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS farms_select_policy ON farms;
DROP POLICY IF EXISTS farms_insert_policy ON farms;
DROP POLICY IF EXISTS farms_update_policy ON farms;
DROP POLICY IF EXISTS farms_delete_policy ON farms;

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

DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

-- 3. REMOVER TODAS AS FUNÇÕES RPC CRIADAS
DROP FUNCTION IF EXISTS get_user_profile();
DROP FUNCTION IF EXISTS get_user_profile_simple(UUID);
DROP FUNCTION IF EXISTS create_initial_farm(TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS create_initial_user(UUID, UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS check_farm_exists(TEXT, TEXT);
DROP FUNCTION IF EXISTS get_farm_statistics(UUID);
DROP FUNCTION IF EXISTS get_user_by_email(TEXT);
DROP FUNCTION IF EXISTS update_user_profile(UUID, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS change_user_password(UUID, TEXT);
DROP FUNCTION IF EXISTS get_farm_users(UUID);
DROP FUNCTION IF EXISTS get_animal_statistics(UUID);
DROP FUNCTION IF EXISTS get_milk_production_stats(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_quality_tests_stats(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_health_records_stats(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_treatments_stats(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_payments_stats(UUID, INTEGER);

-- 4. REMOVER COLUNAS ADICIONADAS NA TABELA USERS (APENAS SE EXISTIREM)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'report_farm_name') THEN
        ALTER TABLE users DROP COLUMN report_farm_name;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'report_farm_logo_base64') THEN
        ALTER TABLE users DROP COLUMN report_farm_logo_base64;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'report_footer_text') THEN
        ALTER TABLE users DROP COLUMN report_footer_text;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'report_system_logo_base64') THEN
        ALTER TABLE users DROP COLUMN report_system_logo_base64;
    END IF;
END $$;

-- 5. REMOVER COLUNAS ADICIONADAS NA TABELA FARMS (APENAS SE EXISTIREM)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'farms' AND column_name = 'cnpj') THEN
        ALTER TABLE farms DROP COLUMN cnpj;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'farms' AND column_name = 'city') THEN
        ALTER TABLE farms DROP COLUMN city;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'farms' AND column_name = 'state') THEN
        ALTER TABLE farms DROP COLUMN state;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'farms' AND column_name = 'animal_count') THEN
        ALTER TABLE farms DROP COLUMN animal_count;
    END IF;
END $$;

-- 6. REMOVER TABELA FINANCIAL_RECORDS SE FOI CRIADA
DROP TABLE IF EXISTS financial_records;

-- 7. RESTAURAR CONSTRAINT ORIGINAL NA TABELA USERS
-- Remover constraint modificada
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_farm_unique;
-- Restaurar constraint original (se existia)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'users_email_unique') THEN
        ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);
    END IF;
END $$;

-- 8. VERIFICAR ESTRUTURA FINAL
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

-- 9. MENSAGEM FINAL
SELECT 'TODAS AS ALTERAÇÕES FORAM REVERTIDAS! O banco voltou ao estado original.' as resultado; 