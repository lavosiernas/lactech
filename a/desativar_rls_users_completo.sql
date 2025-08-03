-- Script para desativar completamente o RLS na tabela users
-- ATENÇÃO: Este script desativa todas as políticas RLS na tabela users
-- Use apenas em caso de emergência quando outras soluções não funcionarem

-- 1. Desabilitar RLS na tabela users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 2. Verificar se RLS foi desabilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'users';

-- 3. Verificar políticas existentes (apenas para referência)
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'users';

-- Instruções para aplicar este script:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Clique em "New query"
-- 5. Cole este script e execute

-- IMPORTANTE: Este script desativa completamente a segurança RLS na tabela users.
-- Isso pode representar um risco de segurança, pois permite acesso irrestrito à tabela.
-- Use apenas temporariamente e reative o RLS assim que possível.