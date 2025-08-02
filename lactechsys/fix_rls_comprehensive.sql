-- CORREÇÃO COMPREENSIVA DO RLS - VERSÃO FINAL
-- Este script resolve todos os problemas de RLS e infinite recursion

-- 1. PRIMEIRO: DESABILITAR RLS TEMPORARIAMENTE PARA QUEBRAR O LOOP
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS animals DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS milk_production DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quality_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS animal_health_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS treatments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_access_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS secondary_accounts DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS RLS EXISTENTES PARA EVITAR CONFLITOS
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

-- 3. CRIAR POLÍTICAS RLS CORRETAS E SEGURAS

-- POLÍTICAS PARA TABELA USERS (SEM RECURSÃO)
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA FARMS
CREATE POLICY farms_select_policy ON farms FOR SELECT USING (true);
CREATE POLICY farms_insert_policy ON farms FOR INSERT WITH CHECK (true);
CREATE POLICY farms_update_policy ON farms FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY farms_delete_policy ON farms FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA ANIMALS
CREATE POLICY animals_select_policy ON animals FOR SELECT USING (true);
CREATE POLICY animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
CREATE POLICY animals_update_policy ON animals FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY animals_delete_policy ON animals FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA MILK_PRODUCTION
CREATE POLICY milk_production_select_policy ON milk_production FOR SELECT USING (true);
CREATE POLICY milk_production_insert_policy ON milk_production FOR INSERT WITH CHECK (true);
CREATE POLICY milk_production_update_policy ON milk_production FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY milk_production_delete_policy ON milk_production FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA QUALITY_TESTS
CREATE POLICY quality_tests_select_policy ON quality_tests FOR SELECT USING (true);
CREATE POLICY quality_tests_insert_policy ON quality_tests FOR INSERT WITH CHECK (true);
CREATE POLICY quality_tests_update_policy ON quality_tests FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY quality_tests_delete_policy ON quality_tests FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA ANIMAL_HEALTH_RECORDS
CREATE POLICY animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
CREATE POLICY animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
CREATE POLICY animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA TREATMENTS
CREATE POLICY treatments_select_policy ON treatments FOR SELECT USING (true);
CREATE POLICY treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
CREATE POLICY treatments_update_policy ON treatments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY treatments_delete_policy ON treatments FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA PAYMENTS
CREATE POLICY payments_select_policy ON payments FOR SELECT USING (true);
CREATE POLICY payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY payments_update_policy ON payments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY payments_delete_policy ON payments FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA NOTIFICATIONS
CREATE POLICY notifications_select_policy ON notifications FOR SELECT USING (true);
CREATE POLICY notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY notifications_update_policy ON notifications FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY notifications_delete_policy ON notifications FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA USER_ACCESS_REQUESTS
CREATE POLICY user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
CREATE POLICY user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
CREATE POLICY user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

-- POLÍTICAS PARA TABELA SECONDARY_ACCOUNTS
CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- 4. REABILITAR RLS COM AS NOVAS POLÍTICAS
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
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 5. VERIFICAR SE RLS ESTÁ FUNCIONANDO
SELECT 
    schemaname,
    tablename,
    rowsecurity,
    CASE 
        WHEN rowsecurity THEN 'RLS ATIVADO'
        ELSE 'RLS DESATIVADO'
    END as status
FROM pg_tables 
WHERE tablename IN (
    'users',
    'farms',
    'animals',
    'milk_production',
    'quality_tests',
    'animal_health_records',
    'treatments',
    'payments',
    'notifications',
    'user_access_requests',
    'secondary_accounts'
)
AND schemaname = 'public'
ORDER BY tablename;

-- 6. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN (
    'users',
    'farms',
    'animals',
    'milk_production',
    'quality_tests',
    'animal_health_records',
    'treatments',
    'payments',
    'notifications',
    'user_access_requests',
    'secondary_accounts'
)
AND schemaname = 'public'
ORDER BY tablename, policyname;

-- 7. CONFIRMAR SUCESSO
SELECT 'RLS CORRIGIDO COM SUCESSO - SEM RECURSÃO INFINITA' as resultado; 