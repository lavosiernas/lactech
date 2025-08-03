-- Script para verificar e adicionar campos de configuração de relatório na tabela users
-- Sistema LacTech - Gestão de Fazendas Leiteiras

-- 1. VERIFICAR SE OS CAMPOS JÁ EXISTEM
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN (
    'report_farm_name',
    'report_farm_logo_base64',
    'report_footer_text',
    'report_system_logo_base64'
)
ORDER BY column_name;

-- 2. ADICIONAR OS CAMPOS SE NÃO EXISTIREM
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_name TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_farm_logo_base64 TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_footer_text TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS report_system_logo_base64 TEXT;

-- 3. ADICIONAR COMENTÁRIOS AOS CAMPOS
COMMENT ON COLUMN users.report_farm_name IS 'Nome personalizado da fazenda para relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_farm_logo_base64 IS 'Logo da fazenda em formato Base64 para relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_footer_text IS 'Texto personalizado do rodapé dos relatórios (específico do usuário)';
COMMENT ON COLUMN users.report_system_logo_base64 IS 'Logo do sistema em formato Base64 para relatórios (específico do usuário)';

-- 4. VERIFICAR SE OS CAMPOS FORAM ADICIONADOS COM SUCESSO
SELECT 
    'Campos de relatório adicionados com sucesso:' as status,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name LIKE 'report_%'
ORDER BY column_name;

-- 5. INICIALIZAR CAMPOS PARA USUÁRIOS EXISTENTES (OPCIONAL)
-- Definir nome da fazenda padrão baseado no nome da fazenda
UPDATE users 
SET report_farm_name = (
    SELECT f.name 
    FROM farms f 
    WHERE f.id = users.farm_id
)
WHERE report_farm_name IS NULL;

-- 6. VERIFICAR QUANTOS USUÁRIOS FORAM ATUALIZADOS
SELECT 
    'Usuários com configurações inicializadas:' as status,
    COUNT(*) as total
FROM users 
WHERE report_farm_name IS NOT NULL;