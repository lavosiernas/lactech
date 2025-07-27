-- Adicionar política RLS para DELETE na tabela users
-- Esta política permite que proprietários e gerentes excluam usuários da mesma fazenda

CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Permite que proprietários e gerentes excluam usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users 
            WHERE id = auth.uid() 
            AND role IN ('proprietario', 'gerente')
        )
        -- Impede que o usuário exclua a si mesmo (opcional - remova se quiser permitir auto-exclusão)
        AND id != auth.uid()
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