-- CRIAR TABELA SECONDARY_ACCOUNTS - VERSÃO SIMPLES
-- Execute este script no Supabase SQL Editor

-- 1. CRIAR TABELA
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    primary_account_id UUID NOT NULL,
    secondary_account_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

-- 3. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE secondary_accounts DISABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR SE A TABELA FOI CRIADA
SELECT 
    'TABELA SECONDARY_ACCOUNTS CRIADA COM SUCESSO' as resultado,
    COUNT(*) as total_registros
FROM secondary_accounts; 