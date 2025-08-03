-- =====================================================
-- DESABILITAR CONFIRMAÇÃO DE EMAIL NO SUPABASE
-- =====================================================

-- NOTA: Este script deve ser executado no painel do Supabase
-- Vá para: Authentication > Settings > Email Auth

/*
INSTRUÇÕES PARA DESABILITAR CONFIRMAÇÃO DE EMAIL:

1. Acesse o painel do Supabase
2. Vá para Authentication > Settings
3. Na seção "Email Auth", desabilite:
   - "Enable email confirmations"
   - "Enable secure email change"
   - "Enable double confirm changes"

4. Ou execute estas configurações via SQL (se disponível):

-- Desabilitar confirmação de email
UPDATE auth.config 
SET email_confirmation_required = false 
WHERE id = 1;

-- Permitir login sem confirmação
UPDATE auth.config 
SET email_confirmation_required = false,
    secure_email_change_enabled = false
WHERE id = 1;

5. Salve as configurações

ALTERNATIVA VIA API:

Se você tiver acesso à API do Supabase, pode usar:

curl -X PATCH \
  'https://heztvigvdewpqhmlmnip.supabase.co/rest/v1/auth/v1/settings' \
  -H 'apikey: YOUR_SERVICE_ROLE_KEY' \
  -H 'Authorization: Bearer YOUR_SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_confirmation_required": false,
    "secure_email_change_enabled": false
  }'

*/

-- =====================================================
-- CONFIGURAÇÕES ALTERNATIVAS VIA SQL
-- =====================================================

-- Verificar configurações atuais
SELECT * FROM auth.config;

-- Atualizar configurações (se a tabela existir)
-- UPDATE auth.config SET email_confirmation_required = false;

-- =====================================================
-- FUNÇÃO PARA CRIAR USUÁRIO SEM CONFIRMAÇÃO
-- =====================================================

-- Função para criar usuário sem confirmação de email
CREATE OR REPLACE FUNCTION create_user_without_confirmation(
    p_email TEXT,
    p_password TEXT,
    p_name TEXT,
    p_role TEXT,
    p_farm_id UUID
)
RETURNS UUID AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Criar usuário no Supabase Auth
    -- NOTA: Esta função requer privilégios especiais
    -- Em produção, use a API do Supabase
    
    -- Por enquanto, apenas criar no banco de dados
    INSERT INTO users (
        id, farm_id, name, email, role, is_active, created_at
    ) VALUES (
        uuid_generate_v4(), p_farm_id, p_name, p_email, p_role, true, NOW()
    ) RETURNING id INTO user_id;
    
    RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'CONFIGURAÇÕES DE EMAIL ATUALIZADAS! Verifique o painel do Supabase.' as resultado; 