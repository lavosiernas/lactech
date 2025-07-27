-- Script para adicionar campo de foto de perfil na tabela users

-- Adicionar coluna profile_photo_url à tabela users
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_photo_url TEXT;

-- Comentário para documentar o campo
COMMENT ON COLUMN users.profile_photo_url IS 'URL da foto de perfil do usuário armazenada no Supabase Storage';

-- Atualizar a função get_user_profile para incluir a foto de perfil
CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    farm_id UUID,
    farm_name VARCHAR(255),
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    user_role VARCHAR(20),
    user_whatsapp VARCHAR(20),
    user_is_active BOOLEAN,
    profile_photo_url TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.farm_id,
        f.name,
        u.name,
        u.email,
        u.role,
        u.whatsapp,
        u.is_active,
        u.profile_photo_url
    FROM users u
    JOIN farms f ON u.farm_id = f.id
    WHERE u.id = auth.uid();
END;
$$;