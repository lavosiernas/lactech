-- SCRIPT DE EMERGÊNCIA - Corrigir Políticas RLS Problemáticas
-- Este script remove as políticas extremamente permissivas e cria políticas seguras

-- 1. REMOVER TODAS AS POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS allow_authenticated_delete ON users;
DROP POLICY IF EXISTS allow_authenticated_insert ON users;
DROP POLICY IF EXISTS allow_authenticated_update ON users;
DROP POLICY IF EXISTS allow_login_select ON users;

-- 2. REMOVER POLÍTICAS CONFLITANTES
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

-- 3. CRIAR POLÍTICAS SEGURAS PARA A TABELA USERS
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Usuário pode ver seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode ver outros usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY users_insert_policy ON users
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Usuário pode criar contas secundárias na mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY users_update_policy ON users
    FOR UPDATE TO authenticated
    USING (
        -- Usuário pode atualizar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode atualizar contas secundárias na mesma fazenda
        (farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        ) AND email IN (
            SELECT email FROM users WHERE id = auth.uid()
        ))
    )
    WITH CHECK (
        -- Usuário pode atualizar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode atualizar contas secundárias na mesma fazenda
        (farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        ) AND email IN (
            SELECT email FROM users WHERE id = auth.uid()
        ))
    );

CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Usuário pode deletar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode deletar contas secundárias na mesma fazenda
        (farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        ) AND email IN (
            SELECT email FROM users WHERE id = auth.uid()
        ))
    );

-- 4. CRIAR POLÍTICAS PARA A TABELA SECONDARY_ACCOUNTS
DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Usuário pode criar relações de conta secundária
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
        -- Usuário pode ver suas próprias relações
        primary_account_id = auth.uid()
        OR
        secondary_account_id = auth.uid()
        OR
        -- Usuário pode ver relações na mesma fazenda
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
        -- Usuário pode atualizar suas próprias relações
        primary_account_id = auth.uid()
        OR
        -- Usuário pode atualizar relações na mesma fazenda
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    )
    WITH CHECK (
        -- Usuário pode atualizar suas próprias relações
        primary_account_id = auth.uid()
        OR
        -- Usuário pode atualizar relações na mesma fazenda
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
        -- Usuário pode deletar suas próprias relações
        primary_account_id = auth.uid()
        OR
        -- Usuário pode deletar relações na mesma fazenda
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id IN (
                SELECT farm_id FROM users WHERE id = auth.uid()
            )
        )
    );

-- 5. VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('users', 'secondary_accounts')
ORDER BY tablename, policyname;

-- 6. TESTAR UMA CONSULTA SIMPLES
-- Esta consulta deve funcionar agora
SELECT COUNT(*) as total_users FROM users WHERE id = auth.uid(); 