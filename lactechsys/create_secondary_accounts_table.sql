-- Script para criar a tabela secondary_accounts
-- Esta tabela rastreia a relação entre contas principais e secundárias

-- Criar a tabela secondary_accounts
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

-- Habilitar RLS (Row Level Security)
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- Criar política RLS para inserção
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

-- Criar política RLS para seleção
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

-- Criar política RLS para atualização
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

-- Criar política RLS para exclusão
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

-- Verificar se a tabela foi criada corretamente
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'secondary_accounts';