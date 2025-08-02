-- VERIFICAR E CRIAR TABELA SECONDARY_ACCOUNTS
-- Este script verifica se a tabela existe e a cria se necessário

-- 1. VERIFICAR SE A TABELA EXISTE
SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NÃO EXISTE'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'secondary_accounts';

-- 2. CRIAR TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    primary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(primary_account_id, secondary_account_id)
);

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

-- 4. HABILITAR RLS NA TABELA
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR POLÍTICAS RLS
DO $$
BEGIN
    -- Política para SELECT
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_select_policy') THEN
        CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
    END IF;
    
    -- Política para INSERT
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_insert_policy') THEN
        CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
    END IF;
    
    -- Política para UPDATE
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_update_policy') THEN
        CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true) WITH CHECK (true);
    END IF;
    
    -- Política para DELETE
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_delete_policy') THEN
        CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);
    END IF;
END $$;

-- 6. VERIFICAR SE A TABELA FOI CRIADA
SELECT 
    table_name,
    'CRIADA COM SUCESSO' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'secondary_accounts';

-- 7. VERIFICAR POLÍTICAS RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'secondary_accounts'
AND schemaname = 'public'
ORDER BY policyname;

-- 8. CONFIRMAR SUCESSO
SELECT 'TABELA SECONDARY_ACCOUNTS VERIFICADA E CONFIGURADA' as resultado; 