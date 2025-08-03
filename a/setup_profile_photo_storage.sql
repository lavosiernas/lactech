-- =====================================================
-- CONFIGURAÇÃO COMPLETA PARA FOTOS DE PERFIL
-- Sistema LacTech - Gestão de Fazendas Leiteiras
-- =====================================================

-- 1. ADICIONAR CAMPO DE FOTO DE PERFIL NA TABELA USERS
-- (Execute apenas se o campo ainda não existir)
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_photo_url TEXT;

-- Adicionar comentário ao campo
COMMENT ON COLUMN users.profile_photo_url IS 'URL da foto de perfil do usuário armazenada no Supabase Storage';

-- 2. CRIAR BUCKET PARA FOTOS DE PERFIL
-- (Execute no painel do Supabase ou via SQL)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-photos',
  'profile-photos',
  true,
  5242880, -- 5MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 3. POLÍTICAS DE SEGURANÇA PARA O STORAGE (RLS)

-- Política para permitir que usuários vejam todas as fotos de perfil (SELECT)
CREATE POLICY "Profile photos are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');

-- Política para permitir que usuários façam upload de suas próprias fotos (INSERT)
CREATE POLICY "Users can upload their own profile photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para permitir que usuários atualizem suas próprias fotos (UPDATE)
CREATE POLICY "Users can update their own profile photos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para permitir que usuários excluam suas próprias fotos (DELETE)
CREATE POLICY "Users can delete their own profile photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. FUNÇÃO AUXILIAR PARA LIMPAR FOTOS ANTIGAS (OPCIONAL)
-- Esta função pode ser usada para remover fotos antigas quando uma nova é enviada
CREATE OR REPLACE FUNCTION clean_old_profile_photos(user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Remove arquivos antigos do storage
  DELETE FROM storage.objects 
  WHERE bucket_id = 'profile-photos' 
    AND name LIKE user_id::text || '_%'
    AND created_at < NOW() - INTERVAL '1 hour';
END;
$$;

-- 5. TRIGGER PARA LIMPAR FOTOS ANTIGAS AUTOMATICAMENTE (OPCIONAL)
-- Este trigger remove fotos antigas quando o profile_photo_url é atualizado
CREATE OR REPLACE FUNCTION trigger_clean_old_photos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Se a URL da foto mudou, limpa fotos antigas
  IF OLD.profile_photo_url IS DISTINCT FROM NEW.profile_photo_url THEN
    PERFORM clean_old_profile_photos(NEW.id);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Criar o trigger
DROP TRIGGER IF EXISTS clean_old_profile_photos_trigger ON users;
CREATE TRIGGER clean_old_profile_photos_trigger
  AFTER UPDATE OF profile_photo_url ON users
  FOR EACH ROW
  EXECUTE FUNCTION trigger_clean_old_photos();

-- 6. FUNÇÃO PARA OBTER PERFIL COM FOTO
-- Remove a função existente e cria uma nova para incluir a foto de perfil
DROP FUNCTION IF EXISTS get_user_profile();

CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE (
    id UUID,
    name TEXT,
    email TEXT,
    whatsapp TEXT,
    role TEXT,
    farm_id UUID,
    farm_name TEXT,
    profile_photo_url TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name,
        u.email,
        u.whatsapp,
        u.role,
        u.farm_id,
        f.name as farm_name,
        u.profile_photo_url,
        u.is_active,
        u.created_at
    FROM users u
    LEFT JOIN farms f ON u.farm_id = f.id
    WHERE u.id = auth.uid();
END;
$$;

-- 7. VERIFICAR SE TUDO FOI CONFIGURADO CORRETAMENTE
-- Execute esta query para verificar se o bucket foi criado
SELECT * FROM storage.buckets WHERE id = 'profile-photos';

-- Execute esta query para verificar as políticas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' AND policyname LIKE '%profile%';

-- Execute esta query para verificar se o campo foi adicionado
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'profile_photo_url';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique se todas as queries foram executadas com sucesso
-- 3. Teste o upload de uma foto de perfil no sistema
-- 4. Verifique se a foto aparece corretamente no perfil e cabeçalho
-- =====================================================

-- OBSERVAÇÕES IMPORTANTES:
-- - O bucket será público para permitir visualização das fotos
-- - Apenas o próprio usuário pode fazer upload/editar/excluir suas fotos
-- - Limite de 5MB por arquivo
-- - Formatos aceitos: JPEG, JPG, PNG, GIF, WEBP
-- - Fotos antigas são automaticamente removidas após 1 hora
-- =====================================================