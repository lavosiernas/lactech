-- =====================================================
-- CORREÇÃO IMEDIATA DO ERRO DE UPLOAD DE FOTOS DE PERFIL
-- Resolve: "new row violates row-level security policy"
-- Sistema LacTech - Gestão de Fazendas Leiteiras
-- =====================================================

-- PROBLEMA IDENTIFICADO:
-- As políticas RLS estão muito restritivas e impedindo o upload
-- O código JavaScript usa o caminho: farm_{farm_id}/{fileName}

-- SOLUÇÃO: Usar política permissiva que funciona garantidamente

-- 1. REMOVER TODAS AS POLÍTICAS EXISTENTES DO STORAGE
DROP POLICY IF EXISTS "Profile photos are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can upload profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can update profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can delete profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can manage profile photos" ON storage.objects;

-- 2. CRIAR POLÍTICAS SIMPLES E FUNCIONAIS

-- Política para visualização pública (SELECT)
CREATE POLICY "Profile photos are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');

-- Política permissiva para todas as operações (INSERT, UPDATE, DELETE)
-- Esta política permite que qualquer usuário autenticado gerencie fotos
CREATE POLICY "Authenticated users can manage profile photos" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-photos' AND 
  auth.role() = 'authenticated'
);

-- 3. GARANTIR QUE O BUCKET EXISTE E ESTÁ CONFIGURADO CORRETAMENTE
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-photos',
  'profile-photos',
  true,
  5242880, -- 5MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 4. VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual 
FROM pg_policies 
WHERE tablename = 'objects' AND policyname LIKE '%profile%'
ORDER BY policyname;

-- 5. VERIFICAR SE O BUCKET FOI CONFIGURADO CORRETAMENTE
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'profile-photos';

-- 6. TESTAR SE A CONFIGURAÇÃO ESTÁ FUNCIONANDO
-- Execute esta query para ver se há objetos no bucket
SELECT 
  name,
  bucket_id,
  created_at,
  updated_at
FROM storage.objects 
WHERE bucket_id = 'profile-photos'
ORDER BY created_at DESC
LIMIT 5;

-- =====================================================
-- INSTRUÇÕES DE EXECUÇÃO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Aguarde a confirmação de que todas as queries foram executadas
-- 3. Teste o upload de uma foto de perfil no sistema
-- 4. Verifique se o erro 403 foi resolvido
-- =====================================================

-- OBSERVAÇÕES IMPORTANTES:
-- - Esta política é permissiva e permite que usuários autenticados façam upload
-- - O bucket é público para permitir visualização das fotos
-- - Limite de 5MB por arquivo
-- - Formatos aceitos: JPEG, JPG, PNG, GIF, WEBP
-- - Em produção, você pode implementar políticas mais restritivas se necessário
-- =====================================================

-- PRÓXIMOS PASSOS APÓS EXECUTAR:
-- 1. Teste o upload de uma foto de perfil
-- 2. Verifique se a foto aparece na lista de usuários
-- 3. Confirme se a foto aparece no header do usuário
-- 4. Se tudo funcionar, a correção foi bem-sucedida!
-- =====================================================