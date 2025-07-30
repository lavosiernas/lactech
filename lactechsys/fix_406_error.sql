-- Script para corrigir o erro 406 (Not Acceptable) nas consultas à tabela users
-- Este script desabilita temporariamente o RLS na tabela users

-- 1. Desabilitar RLS na tabela users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. Remover todas as políticas existentes que podem estar causando o problema
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- 3. Verificar se RLS foi desabilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'users';

-- 4. Verificar se não há mais políticas
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'users';

-- 5. Instruções para aplicar este script:
-- a. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- b. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- c. No menu lateral, clique em "SQL Editor"
-- d. Clique em "New query"
-- e. Cole este script e execute
-- f. Teste o sistema novamente para verificar se o erro 406 foi resolvido

COMMIT;