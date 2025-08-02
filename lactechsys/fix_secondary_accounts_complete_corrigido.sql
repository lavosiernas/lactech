-- Script completo para corrigir problemas com contas secundárias
-- Este script resolve os erros 404, 406 e 409
-- VERSÃO CORRIGIDA - Sem erros de sintaxe

-- 1. Criar a tabela secondary_accounts se não existir
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT secondary_accounts_unique UNIQUE (primary_account_id, secondary_account_id)
);

-- 2. Adicionar índices para melhorar a performance
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

-- 3. Habilitar RLS na tabela secondary_accounts
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 4. Remover políticas RLS problemáticas da tabela users
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- 5. Criar políticas RLS corretas para a tabela users
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Permitir acesso ao próprio perfil
        id = auth.uid()
        OR
        -- Permitir consultas por email e farm_id (necessário para contas secundárias)
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        OR
        -- Permitir consultas para verificar contas secundárias
        email IN (
            SELECT email FROM users 
            WHERE id = auth.uid() 
            AND farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        )
    );

CREATE POLICY users_insert_policy ON users
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Permitir inserção de contas secundárias
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        OR
        -- Permitir inserção de novos usuários na mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users 
            WHERE id = auth.uid() 
            AND role IN ('proprietario', 'gerente')
        )
    );

CREATE POLICY users_update_policy ON users
    FOR UPDATE TO authenticated
    USING (
        -- Permitir atualização do próprio perfil
        id = auth.uid()
        OR
        -- Permitir atualização de contas secundárias
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        AND email IN (
            SELECT email FROM users 
            WHERE id = auth.uid() 
            AND farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        )
    )
    WITH CHECK (
        -- Permitir atualização do próprio perfil
        id = auth.uid()
        OR
        -- Permitir atualização de contas secundárias
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        AND email IN (
            SELECT email FROM users 
            WHERE id = auth.uid() 
            AND farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        )
    );

CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Permitir exclusão do próprio perfil
        id = auth.uid()
        OR
        -- Permitir exclusão de contas secundárias
        farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        AND email IN (
            SELECT email FROM users 
            WHERE id = auth.uid() 
            AND farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid())
        )
    );

-- 6. Criar políticas RLS para a tabela secondary_accounts
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts
    FOR INSERT TO authenticated
    WITH CHECK (
        primary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY secondary_accounts_select_policy ON secondary_accounts
    FOR SELECT TO authenticated
    USING (
        primary_account_id = auth.uid()
        OR
        secondary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY secondary_accounts_update_policy ON secondary_accounts
    FOR UPDATE TO authenticated
    USING (
        primary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    )
    WITH CHECK (
        primary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts
    FOR DELETE TO authenticated
    USING (
        primary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    );

-- 7. Verificar se a restrição UNIQUE no email está causando problemas
-- Se necessário, remover a restrição UNIQUE do email e criar uma restrição composta
-- Esta parte só deve ser executada se houver problemas com emails duplicados

-- Verificar se existe restrição UNIQUE no email
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'users_email_key' 
        AND table_name = 'users'
    ) THEN
        -- Remover a restrição UNIQUE do email
        ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_key;
        
        -- Criar uma restrição composta que permite emails duplicados em diferentes fazendas
        ALTER TABLE users ADD CONSTRAINT users_email_farm_unique 
        UNIQUE (email, farm_id);
        
        RAISE NOTICE 'Restrição UNIQUE do email removida e restrição composta criada';
    ELSE
        RAISE NOTICE 'Restrição UNIQUE do email não encontrada';
    END IF;
END $$;

-- 8. Verificar se as tabelas foram criadas corretamente
SELECT 'secondary_accounts' as table_name, COUNT(*) as row_count FROM secondary_accounts
UNION ALL
SELECT 'users' as table_name, COUNT(*) as row_count FROM users;

-- 9. Mostrar as políticas RLS ativas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename IN ('users', 'secondary_accounts')
ORDER BY tablename, policyname; 