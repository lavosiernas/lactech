-- Versão alternativa: Política RLS para DELETE na tabela users (permite auto-exclusão)
-- Esta política permite que proprietários e gerentes excluam usuários da mesma fazenda,
-- incluindo a si mesmos

-- Primeiro, remover a política anterior se existir
DROP POLICY IF EXISTS users_delete_policy ON users;

-- Criar nova política que permite auto-exclusão
CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Permite que proprietários e gerentes excluam usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users 
            WHERE id = auth.uid() 
            AND role IN ('proprietario', 'gerente')
        )
    );

-- Verificar se a política foi criada corretamente
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users' AND policyname = 'users_delete_policy';