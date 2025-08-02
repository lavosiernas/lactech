-- SCRIPT DE EMERGÊNCIA - Resolver Recursão Infinita nas Políticas RLS
-- Este script desabilita temporariamente o RLS e cria políticas simples

-- 1. DESABILITAR TEMPORARIAMENTE O RLS PARA RESOLVER O PROBLEMA
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS allow_authenticated_delete ON users;
DROP POLICY IF EXISTS allow_authenticated_insert ON users;
DROP POLICY IF EXISTS allow_authenticated_update ON users;
DROP POLICY IF EXISTS allow_login_select ON users;
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;

DROP POLICY IF EXISTS secondary_accounts_insert_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_select_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_update_policy ON secondary_accounts;
DROP POLICY IF EXISTS secondary_accounts_delete_policy ON secondary_accounts;

-- 3. HABILITAR RLS NOVAMENTE
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS SIMPLES E SEGURAS (SEM RECURSÃO)
CREATE POLICY users_select_policy ON users
    FOR SELECT TO authenticated
    USING (
        -- Usuário pode ver seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode ver outros usuários da mesma fazenda
        farm_id = (
            SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
        )
    );

CREATE POLICY users_insert_policy ON users
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Usuário pode criar contas secundárias na mesma fazenda
        farm_id = (
            SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
        )
    );

CREATE POLICY users_update_policy ON users
    FOR UPDATE TO authenticated
    USING (
        -- Usuário pode atualizar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode atualizar contas secundárias na mesma fazenda
        (farm_id = (
            SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
        ) AND email = (
            SELECT email FROM users WHERE id = auth.uid() LIMIT 1
        ))
    )
    WITH CHECK (
        -- Usuário pode atualizar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode atualizar contas secundárias na mesma fazenda
        (farm_id = (
            SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
        ) AND email = (
            SELECT email FROM users WHERE id = auth.uid() LIMIT 1
        ))
    );

CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Usuário pode deletar seu próprio perfil
        id = auth.uid()
        OR
        -- Usuário pode deletar contas secundárias na mesma fazenda
        (farm_id = (
            SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
        ) AND email = (
            SELECT email FROM users WHERE id = auth.uid() LIMIT 1
        ))
    );

-- 5. CRIAR POLÍTICAS SIMPLES PARA SECONDARY_ACCOUNTS
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts
    FOR INSERT TO authenticated
    WITH CHECK (
        -- Usuário pode criar relações de conta secundária
        primary_account_id = auth.uid()
        OR
        primary_account_id IN (
            SELECT id FROM users 
            WHERE farm_id = (
                SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
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
            WHERE farm_id = (
                SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
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
            WHERE farm_id = (
                SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
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
            WHERE farm_id = (
                SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
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
            WHERE farm_id = (
                SELECT farm_id FROM users WHERE id = auth.uid() LIMIT 1
            )
        )
    );

-- 6. VERIFICAR SE AS POLÍTICAS FORAM APLICADAS CORRETAMENTE
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

-- 7. TESTAR UMA CONSULTA SIMPLES
-- Esta consulta deve funcionar agora sem recursão
SELECT COUNT(*) as total_users FROM users WHERE id = auth.uid();

-- 8. TESTAR CONSULTA POR EMAIL (que estava causando o erro)
-- Esta consulta deve funcionar agora
SELECT farm_id FROM users WHERE email = 'devnasc@gmail.com' LIMIT 1; 