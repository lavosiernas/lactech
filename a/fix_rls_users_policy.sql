-- Script para corrigir o erro 406 (Not Acceptable) nas consultas à tabela users
-- Este script modifica a política RLS para permitir consultas específicas sem desabilitar completamente o RLS

-- 1. Remover a política existente que pode estar causando o problema
DROP POLICY IF EXISTS users_select_policy ON users;

-- 2. Criar uma nova política mais permissiva para SELECT
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Permitir acesso ao próprio perfil
        id = auth.uid()
        OR
        -- Permitir acesso a usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
        OR
        -- Permitir consultas específicas por email e farm_id (necessário para contas secundárias)
        EXISTS (
            SELECT 1 FROM users AS u 
            WHERE u.id = auth.uid() AND u.farm_id = users.farm_id
        )
    );

-- 3. Verificar se a política foi criada corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users' AND policyname = 'users_select_policy';

-- 4. Instruções para aplicar este script:
-- a) Acesse o Dashboard do Supabase (https://app.supabase.io)
-- b) Selecione o projeto: lzqbzztoawjnqwgffhjv
-- c) No menu lateral, clique em "SQL Editor"
-- d) Clique em "New query"
-- e) Cole este script e execute
-- f) Teste o sistema novamente para verificar se o erro 406 foi resolvido