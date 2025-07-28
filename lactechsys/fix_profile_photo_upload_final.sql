

-- 1. VERIFICAR SE O BUCKET EXISTE
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets 
WHERE id = 'profile-photos';

-- 2. CRIAR BUCKET SE NÃO EXISTIR
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

-- 3. REMOVER TODAS AS POLÍTICAS EXISTENTES PARA EVITAR CONFLITOS
DROP POLICY IF EXISTS "Profile photos are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can upload profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can update profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Farm users can delete profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can manage profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads to profile-photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow public access to profile-photos" ON storage.objects;

-- 4. CRIAR POLÍTICAS SIMPLES E PERMISSIVAS

-- Política para visualização pública (SELECT)
CREATE POLICY "Allow public access to profile-photos" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');

-- Política permissiva para todas as operações de usuários autenticados
CREATE POLICY "Allow authenticated uploads to profile-photos" ON storage.objects
FOR ALL TO authenticated
USING (bucket_id = 'profile-photos')
WITH CHECK (bucket_id = 'profile-photos');

-- 5. VERIFICAR SE AS POLÍTICAS FORAM CRIADAS
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

-- 6. VERIFICAR CONFIGURAÇÃO FINAL DO BUCKET
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at,
  updated_at
FROM storage.buckets 
WHERE id = 'profile-photos';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se o bucket foi criado/atualizado corretamente
-- 3. Verifique se as políticas foram aplicadas
-- 4. Teste o upload de uma foto de perfil
-- 5. Monitore os logs do console para verificar o funcionamento
-- =====================================================

-- OBSERVAÇÕES IMPORTANTES:
-- - Esta configuração é mais permissiva para resolver problemas de RLS
-- - O bucket é público para permitir visualização das fotos
-- - Usuários autenticados podem fazer upload, atualizar e excluir fotos
-- - Limite de 5MB por arquivo
-- - Formatos aceitos: JPEG, JPG, PNG, GIF, WEBP
-- =====================================================