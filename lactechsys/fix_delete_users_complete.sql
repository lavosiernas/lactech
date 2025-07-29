-- Script completo para corrigir exclusão de usuários
-- Este script garante que as políticas RLS estejam corretas

-- 1. Remover política existente se houver
DROP POLICY IF EXISTS users_delete_policy ON users;

-- 2. Criar nova política RLS para DELETE
CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Permite que proprietários e gerentes excluam usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users 
            WHERE id = auth.uid() 
            AND role IN ('proprietario', 'gerente')
        )
        -- Permite auto-exclusão também (removido a restrição AND id != auth.uid())
    );

-- 3. Verificar se RLS está habilitado na tabela users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 4. Verificar todas as políticas da tabela users
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users'
ORDER BY cmd, policyname;

-- 5. Testar se o usuário atual pode excluir (substitua USER_ID_TO_TEST pelo ID real)
-- SELECT * FROM users WHERE id = 'USER_ID_TO_TEST';
-- DELETE FROM users WHERE id = 'USER_ID_TO_TEST';

COMMIT;