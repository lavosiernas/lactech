-- =====================================================
-- CORREÇÃO DO ERRO DE UPLOAD DE FOTOS DE PERFIL
-- Resolve o erro: "new row violates row-level security policy"
-- Sistema LacTech - Gestão de Fazendas Leiteiras
-- =====================================================

-- 1. REMOVER POLÍTICAS RESTRITIVAS EXISTENTES
DROP POLICY IF EXISTS "Profile photos are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can upload profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can update profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can delete profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can manage profile photos" ON storage.objects;

-- 2. CRIAR POLÍTICAS MAIS PERMISSIVAS PARA RESOLVER O PROBLEMA

-- Política para visualização pública das fotos (SELECT)
CREATE POLICY "Profile photos are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');

-- Política permissiva para upload, atualização e exclusão (INSERT, UPDATE, DELETE)
CREATE POLICY "Authenticated users can manage profile photos" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-photos' AND 
  auth.role() = 'authenticated'
);

-- 3. VERIFICAR SE O BUCKET EXISTE E ESTÁ CONFIGURADO CORRETAMENTE
-- Se o bucket não existir, será criado automaticamente
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

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se as políticas foram criadas com sucesso
-- 3. Teste o upload de uma foto de perfil
-- 4. Se ainda houver problemas, verifique os logs do console
-- =====================================================

-- OBSERVAÇÕES IMPORTANTES:
-- - Esta política é mais permissiva e permite que qualquer usuário autenticado
--   faça upload de fotos no bucket profile-photos
-- - Em produção, você pode querer políticas mais restritivas
-- - O bucket é público para permitir visualização das fotos
-- - Limite de 5MB por arquivo
-- =====================================================