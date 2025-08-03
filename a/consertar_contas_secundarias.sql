-- Script para consertar o problema das contas secundárias SEM alterar políticas RLS
-- Este script implementa a solução recomendada modificando apenas a restrição de email

-- PARTE 1: Modificar a restrição de email único na tabela users
-- Isso permite emails duplicados desde que estejam em fazendas diferentes ou tenham IDs diferentes
DO $$
DECLARE
    constraint_name text;
BEGIN
    -- 1. Identificar o nome da restrição de unicidade do email
    SELECT conname INTO constraint_name
    FROM pg_constraint
    WHERE conrelid = 'users'::regclass
    AND contype = 'u'
    AND array_position(conkey, (
        SELECT attnum
        FROM pg_attribute
        WHERE attrelid = 'users'::regclass
        AND attname = 'email'
    )) IS NOT NULL;
    
    -- 2. Remover a restrição de unicidade do email
    IF constraint_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE users DROP CONSTRAINT ' || constraint_name;
        RAISE NOTICE 'Restrição % removida com sucesso', constraint_name;
    ELSE
        RAISE NOTICE 'Restrição de unicidade para email não encontrada';
    END IF;
    
    -- 3. Adicionar uma restrição composta para email, farm_id e id
    -- Isso permite emails duplicados desde que tenham IDs diferentes
    BEGIN
        ALTER TABLE users ADD CONSTRAINT users_email_farm_id_unique 
        UNIQUE (email, farm_id, id);
        RAISE NOTICE 'Nova restrição composta adicionada com sucesso';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'A restrição composta já existe';
    END;
END $$;

-- PARTE 2: Criar a tabela secondary_accounts se não existir
-- Esta tabela rastreia a relação entre contas principais e secundárias
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    secondary_account_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT secondary_accounts_unique UNIQUE (primary_account_id, secondary_account_id)
);

-- Adicionar índices para melhorar a performance
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

-- Verificar se RLS já está habilitado na tabela secondary_accounts
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE tablename = 'secondary_accounts' AND rowsecurity = true
    ) THEN
        -- Habilitar RLS (Row Level Security)
        ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- Criar políticas RLS para a tabela secondary_accounts apenas se não existirem
DO $$
BEGIN 
    -- Política para inserção
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_insert_policy'
    ) THEN
        CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts
            FOR INSERT TO authenticated
            WITH CHECK (
                primary_account_id = auth.uid() OR
                primary_account_id IN (
                    SELECT id FROM users 
                    WHERE farm_id IN (
                        SELECT farm_id FROM users WHERE id = auth.uid()
                    ) AND
                    role IN ('proprietario', 'gerente')
                )
            );
    END IF;
    
    -- Política para seleção
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_select_policy'
    ) THEN
        CREATE POLICY secondary_accounts_select_policy ON secondary_accounts
            FOR SELECT TO authenticated
            USING (
                primary_account_id = auth.uid() OR
                secondary_account_id = auth.uid() OR
                primary_account_id IN (
                    SELECT id FROM users 
                    WHERE farm_id IN (
                        SELECT farm_id FROM users WHERE id = auth.uid()
                    )
                )
            );
    END IF;
    
    -- Política para atualização
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_update_policy'
    ) THEN
        CREATE POLICY secondary_accounts_update_policy ON secondary_accounts
            FOR UPDATE TO authenticated
            USING (
                primary_account_id = auth.uid() OR
                primary_account_id IN (
                    SELECT id FROM users 
                    WHERE farm_id IN (
                        SELECT farm_id FROM users WHERE id = auth.uid()
                    ) AND
                    role IN ('proprietario', 'gerente')
                )
            )
            WITH CHECK (
                primary_account_id = auth.uid() OR
                primary_account_id IN (
                    SELECT id FROM users 
                    WHERE farm_id IN (
                        SELECT farm_id FROM users WHERE id = auth.uid()
                    ) AND
                    role IN ('proprietario', 'gerente')
                )
            );
    END IF;
    
    -- Política para exclusão
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'secondary_accounts' AND policyname = 'secondary_accounts_delete_policy'
    ) THEN
        CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts
            FOR DELETE TO authenticated
            USING (
                primary_account_id = auth.uid() OR
                primary_account_id IN (
                    SELECT id FROM users 
                    WHERE farm_id IN (
                        SELECT farm_id FROM users WHERE id = auth.uid()
                    ) AND
                    role IN ('proprietario', 'gerente')
                )
            );
    END IF;
END $$;

-- Verificar se as alterações foram aplicadas corretamente
SELECT 'Restrição de email modificada' AS alteracao, conname, contype
FROM pg_constraint
WHERE conrelid = 'users'::regclass
AND contype = 'u';

SELECT 'Tabela secondary_accounts criada' AS alteracao, table_name
FROM information_schema.tables
WHERE table_name = 'secondary_accounts';

SELECT 'Políticas RLS para secondary_accounts' AS alteracao, policyname, cmd
FROM pg_policies
WHERE tablename = 'secondary_accounts';

-- Instruções para aplicar este script:
-- 1. Acesse o Dashboard do Supabase (https://app.supabase.io)
-- 2. Selecione o projeto: lzqbzztoawjnqwgffhjv
-- 3. No menu lateral, clique em "SQL Editor"
-- 4. Clique em "New query"
-- 5. Cole este script e execute