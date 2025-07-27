-- =====================================================
-- CORREÇÃO COMPLETA DAS POLÍTICAS RLS - LACTECH
-- Este script resolve todos os problemas de acesso do sistema
-- =====================================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE PARA CORREÇÃO
ALTER TABLE farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE animals DISABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production DISABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE animal_health_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE treatments DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_access_requests DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS farms_insert_policy ON farms;
DROP POLICY IF EXISTS farms_select_policy ON farms;
DROP POLICY IF EXISTS farms_update_policy ON farms;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS animals_policy ON animals;
DROP POLICY IF EXISTS milk_production_policy ON milk_production;
DROP POLICY IF EXISTS quality_tests_policy ON quality_tests;
DROP POLICY IF EXISTS animal_health_records_policy ON animal_health_records;
DROP POLICY IF EXISTS treatments_policy ON treatments;
DROP POLICY IF EXISTS payments_policy ON payments;
DROP POLICY IF EXISTS notifications_policy ON notifications;
DROP POLICY IF EXISTS user_access_requests_policy ON user_access_requests;

-- 3. CRIAR POLÍTICAS MAIS PERMISSIVAS PARA RESOLVER PROBLEMAS IMEDIATOS

-- Política para tabela farms - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access farms" ON farms
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela users - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access users" ON users
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela animals - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access animals" ON animals
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela milk_production - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access milk_production" ON milk_production
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela quality_tests - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access quality_tests" ON quality_tests
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela animal_health_records - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access animal_health_records" ON animal_health_records
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela treatments - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access treatments" ON treatments
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela payments - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access payments" ON payments
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela notifications - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access notifications" ON notifications
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela user_access_requests - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access user_access_requests" ON user_access_requests
FOR ALL USING (auth.role() = 'authenticated');

-- 4. REABILITAR RLS COM AS NOVAS POLÍTICAS
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

-- 5. CONFIGURAR STORAGE PARA FOTOS DE PERFIL
-- Remover políticas restritivas do storage
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can manage profile photos" ON storage.objects;

-- Criar política mais permissiva para storage
CREATE POLICY "Authenticated users can manage profile photos" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-photos' AND 
  auth.role() = 'authenticated'
);

-- 6. VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('farms', 'users', 'animals', 'milk_production', 'quality_tests', 'animal_health_records', 'treatments', 'payments', 'notifications', 'user_access_requests')
ORDER BY tablename, policyname;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Teste o sistema para verificar se está funcionando
-- 3. Se ainda houver problemas, execute o script disable_rls_temp.sql
-- 4. Monitore os logs para identificar consultas específicas que falham
-- =====================================================

-- OBSERVAÇÕES:
-- - Estas políticas são mais permissivas para resolver problemas imediatos
-- - Em produção, considere políticas mais restritivas baseadas em farm_id
-- - Sempre teste em ambiente de desenvolvimento primeiro
-- ===================================================== 