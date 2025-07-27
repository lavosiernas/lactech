-- =====================================================
-- CORREÇÃO DAS POLÍTICAS RLS PARA O SISTEMA LACTECH
-- Execute este script para corrigir problemas de acesso
-- =====================================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE PARA CORREÇÃO
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production DISABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER POLÍTICAS EXISTENTES QUE PODEM ESTAR CAUSANDO PROBLEMAS
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can view farm data" ON farms;
DROP POLICY IF EXISTS "Users can view milk production" ON milk_production;
DROP POLICY IF EXISTS "Users can insert milk production" ON milk_production;
DROP POLICY IF EXISTS "Users can update milk production" ON milk_production;
DROP POLICY IF EXISTS "Users can view quality tests" ON quality_tests;
DROP POLICY IF EXISTS "Users can insert quality tests" ON quality_tests;
DROP POLICY IF EXISTS "Users can view payments" ON payments;
DROP POLICY IF EXISTS "Users can insert payments" ON payments;

-- 3. CRIAR POLÍTICAS MAIS PERMISSIVAS PARA USUÁRIOS AUTENTICADOS

-- Política para tabela users - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access users" ON users
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela farms - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access farms" ON farms
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela milk_production - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access milk_production" ON milk_production
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela quality_tests - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access quality_tests" ON quality_tests
FOR ALL USING (auth.role() = 'authenticated');

-- Política para tabela payments - permite acesso completo para usuários autenticados
CREATE POLICY "Authenticated users can access payments" ON payments
FOR ALL USING (auth.role() = 'authenticated');

-- 4. REABILITAR RLS COM AS NOVAS POLÍTICAS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- 5. VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('users', 'farms', 'milk_production', 'quality_tests', 'payments')
ORDER BY tablename, policyname;

-- 6. POLÍTICA ESPECIAL PARA STORAGE (se necessário)
-- Remover políticas restritivas do storage
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;

-- Criar política mais permissiva para storage
CREATE POLICY "Authenticated users can manage profile photos" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-photos' AND 
  auth.role() = 'authenticated'
);

-- =====================================================
-- INSTRUÇÕES:
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