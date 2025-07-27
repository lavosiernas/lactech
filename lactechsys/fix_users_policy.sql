-- Corrigir política RLS da tabela users para evitar dependência circular

-- Remover política existente
DROP POLICY IF EXISTS users_select_policy ON users;

-- Criar nova política corrigida
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        id = auth.uid() OR
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );