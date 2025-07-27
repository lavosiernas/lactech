-- =====================================================
-- MIGRAÇÃO DAS CONFIGURAÇÕES DE RELATÓRIOS PARA O PERFIL DO USUÁRIO
-- Sistema LacTech - Gestão de Fazendas Leiteiras
-- =====================================================

-- 1. ADICIONAR CAMPOS DE CONFIGURAÇÕES DE RELATÓRIO NA TABELA USERS
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_logo_base64 TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_footer_text VARCHAR(500);
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_system_logo_base64 TEXT;

-- Adicionar comentários aos campos
COMMENT ON COLUMN users.report_farm_name IS 'Nome personalizado da fazenda para relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_farm_logo_base64 IS 'Logo da fazenda em formato Base64 para relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_footer_text IS 'Texto personalizado do rodapé dos relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_system_logo_base64 IS 'Logo do sistema em formato Base64 para relatórios (específico do usuário)';

-- 2. MIGRAR DADOS EXISTENTES DA TABELA FARM_SETTINGS PARA USERS
-- (Apenas se existirem dados na farm_settings)
UPDATE users 
SET 
    report_farm_name = COALESCE(
        (SELECT fs.farm_name FROM farm_settings fs WHERE fs.farm_id = users.farm_id LIMIT 1),
        (SELECT f.name FROM farms f WHERE f.id = users.farm_id)
    ),
    report_farm_logo_base64 = (
        SELECT fs.farm_logo FROM farm_settings fs WHERE fs.farm_id = users.farm_id LIMIT 1
    )
WHERE users.report_farm_name IS NULL;

-- 3. DEFINIR LOGO DO SISTEMA EM BASE64 PARA TODOS OS USUÁRIOS
-- Convertendo a URL https://i.postimg.cc/vmrkgDcB/lactech.png para Base64
-- (Esta é uma representação simplificada - você deve converter a imagem real)
UPDATE users 
SET report_system_logo_base64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
WHERE report_system_logo_base64 IS NULL;

-- 4. ATUALIZAR A FUNÇÃO GET_USER_PROFILE PARA INCLUIR AS CONFIGURAÇÕES DE RELATÓRIO
DROP FUNCTION IF EXISTS get_user_profile();

CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    farm_id UUID,
    farm_name VARCHAR(255),
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    user_role VARCHAR(20),
    user_whatsapp VARCHAR(20),
    profile_photo_url TEXT,
    report_farm_name VARCHAR(255),
    report_farm_logo_base64 TEXT,
    report_footer_text VARCHAR(500),
    report_system_logo_base64 TEXT
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
        u.profile_photo_url,
        COALESCE(u.report_farm_name, f.name) as report_farm_name,
        u.report_farm_logo_base64,
        COALESCE(u.report_footer_text, 'LacTech Milk © ' || EXTRACT(YEAR FROM NOW())) as report_footer_text,
        u.report_system_logo_base64
    FROM users u
    JOIN farms f ON u.farm_id = f.id
    WHERE u.id = auth.uid();
END;
$$;

-- 5. CRIAR FUNÇÃO PARA ATUALIZAR CONFIGURAÇÕES DE RELATÓRIO DO USUÁRIO
CREATE OR REPLACE FUNCTION update_user_report_settings(
    p_report_farm_name VARCHAR(255) DEFAULT NULL,
    p_report_farm_logo_base64 TEXT DEFAULT NULL,
    p_report_footer_text VARCHAR(500) DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE users 
    SET 
        report_farm_name = COALESCE(p_report_farm_name, report_farm_name),
        report_farm_logo_base64 = COALESCE(p_report_farm_logo_base64, report_farm_logo_base64),
        report_footer_text = COALESCE(p_report_footer_text, report_footer_text),
        updated_at = NOW()
    WHERE id = auth.uid();
    
    RETURN FOUND;
END;
$$;

-- 6. CRIAR POLÍTICAS RLS PARA OS NOVOS CAMPOS
-- (As políticas existentes da tabela users já cobrem estes campos)

-- 7. OPCIONAL: REMOVER A TABELA FARM_SETTINGS SE NÃO FOR MAIS NECESSÁRIA
-- (Descomente apenas se tiver certeza de que não é mais usada)
-- DROP TABLE IF EXISTS farm_settings CASCADE;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Atualize o frontend para usar get_user_profile() em vez de farm_settings
-- 3. Use a função update_user_report_settings() para salvar configurações
-- 4. Mova a seção "Configurações de Relatórios" para o modal de perfil
-- =====================================================

-- Verificar se a migração foi bem-sucedida
SELECT 
    'Usuários com configurações migradas:' as status,
    COUNT(*) as total
FROM users 
WHERE report_farm_name IS NOT NULL;

SELECT 
    'Campos adicionados com sucesso:' as status,
    column_name
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name LIKE 'report_%';