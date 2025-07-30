-- Script para reverter as alterações feitas pelo script ativar_politica_rls_users.sql
-- Este script NÃO remove as políticas RLS existentes, apenas garante que o sistema volte ao estado anterior

-- 1. Verificar se a política users_select_policy existe e qual sua definição atual
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users' AND policyname = 'users_select_policy';

-- 2. Manter RLS habilitado, mas ajustar a política para o estado anterior
-- Este comando NÃO remove a política, apenas a modifica para o estado anterior
-- que permitia apenas acesso ao próprio perfil
ALTER POLICY users_select_policy ON users
    USING (id = auth.uid());

-- 3. Verificar se a política foi modificada corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users' AND policyname = 'users_select_policy';

-- Instruções para aplicar este script:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Clique em "New query"
-- 5. Cole este script e execute