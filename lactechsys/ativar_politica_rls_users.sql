-- Script para ativar a política RLS na tabela users sem removê-la
-- Este script garante que a política RLS esteja ativada e funcionando corretamente

-- 1. Garantir que RLS está habilitado na tabela users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 2. Verificar se a política users_select_policy já existe
-- Se não existir, criar uma política que permita consultas necessárias para contas secundárias
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'users' AND policyname = 'users_select_policy'
    ) THEN
        -- Criar política que permite consultas necessárias para contas secundárias
        EXECUTE 'CREATE POLICY users_select_policy ON users
            FOR SELECT TO authenticated
            USING (
                -- Permitir acesso ao próprio perfil
                id = auth.uid()
                OR
                -- Permitir consultas por email e farm_id (necessário para contas secundárias)
                farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
            )';
    END IF;
END
$$;

-- 3. Verificar se as políticas foram criadas corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users';

-- 4. Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'users';

-- Instruções para aplicar este script:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Clique em "New query"
-- 5. Cole este script e execute