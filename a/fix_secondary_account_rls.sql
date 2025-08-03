-- Script para corrigir o erro 406 nas contas secundárias sem desativar RLS
-- Este script modifica apenas o necessário para o funcionamento das contas secundárias

-- Remover política existente que pode estar causando o problema
DROP POLICY IF EXISTS users_select_policy ON users;

-- Criar política que permite consultas necessárias para contas secundárias
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Permitir acesso ao próprio perfil
        id = auth.uid()
        OR
        -- Permitir consultas por email e farm_id (necessário para contas secundárias)
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
    );

-- Instruções:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Cole este script e execute