-- Script para reverter a criação da tabela secondary_accounts

-- Remover os índices primeiro
DROP INDEX IF EXISTS idx_secondary_accounts_primary;
DROP INDEX IF EXISTS idx_secondary_accounts_secondary;

-- Remover a tabela secondary_accounts
DROP TABLE IF EXISTS secondary_accounts;

-- Instruções para aplicar este script:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Clique em "New query"
-- 5. Cole este script e execute
-- 6. Confirme que a tabela foi removida verificando no Editor de Banco de Dados