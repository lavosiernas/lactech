-- =====================================================
-- CORREÇÃO DAS POLÍTICAS RLS PARA FOTOS DE PERFIL
-- Permite que gerentes façam upload de fotos para usuários da mesma fazenda
-- Sistema LacTech - Gestão de Fazendas Leiteiras
-- =====================================================

-- 1. REMOVER POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Profile photos are publicly viewable" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;

-- 2. CRIAR NOVAS POLÍTICAS BASEADAS EM FARM_ID

-- Política para permitir que usuários vejam todas as fotos de perfil (SELECT)
CREATE POLICY "Profile photos are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');

-- Política para permitir que usuários da mesma fazenda façam upload de fotos (INSERT)
CREATE POLICY "Farm users can upload profile photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-photos' AND 
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND (
      -- O usuário pode fazer upload da própria foto
      auth.uid()::text = (storage.foldername(name))[1]
      OR
      -- Ou gerentes podem fazer upload para usuários da mesma fazenda
      (
        users.role = 'gerente' AND
        (storage.foldername(name))[1] LIKE 'farm_' || users.farm_id::text || '%'
      )
    )
  )
);

-- Política para permitir que usuários da mesma fazenda atualizem fotos (UPDATE)
CREATE POLICY "Farm users can update profile photos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-photos' AND 
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND (
      -- O usuário pode atualizar a própria foto
      auth.uid()::text = (storage.foldername(name))[1]
      OR
      -- Ou gerentes podem atualizar fotos de usuários da mesma fazenda
      (
        users.role = 'gerente' AND
        (storage.foldername(name))[1] LIKE 'farm_' || users.farm_id::text || '%'
      )
    )
  )
);

-- Política para permitir que usuários da mesma fazenda excluam fotos (DELETE)
CREATE POLICY "Farm users can delete profile photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-photos' AND 
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND (
      -- O usuário pode excluir a própria foto
      auth.uid()::text = (storage.foldername(name))[1]
      OR
      -- Ou gerentes podem excluir fotos de usuários da mesma fazenda
      (
        users.role = 'gerente' AND
        (storage.foldername(name))[1] LIKE 'farm_' || users.farm_id::text || '%'
      )
    )
  )
);

-- 3. VERIFICAR SE AS POLÍTICAS FORAM CRIADAS CORRETAMENTE
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' AND policyname LIKE '%profile%';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se todas as políticas foram criadas com sucesso
-- 3. Teste o upload de uma foto de perfil de um novo usuário
-- 4. Verifique se a foto aparece corretamente na lista de usuários
-- =====================================================

-- OBSERVAÇÕES IMPORTANTES:
-- - Agora os gerentes podem fazer upload de fotos para usuários da mesma fazenda
-- - O caminho das fotos agora usa farm_id: farm_{farm_id}/{filename}
-- - As fotos continuam públicas para visualização
-- - Apenas usuários da mesma fazenda podem gerenciar as fotos
-- =====================================================