-- RESTAURAR POLÍTICAS RLS FUNCIONAIS
-- Baseado no schema do sistema, estas políticas devem funcionar

-- 1. HABILITAR RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 2. REMOVER POLÍTICAS EXISTENTES
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

-- 3. CRIAR POLÍTICAS FUNCIONAIS PARA USERS
-- Política que permite acesso amplo mas controlado
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
        OR
        -- Permitir consultas por email (necessário para contas secundárias)
        email IN (
            SELECT email FROM users WHERE id = auth.uid()
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

-- 4. CRIAR POLÍTICAS PARA SECONDARY_ACCOUNTS
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

-- 5. CRIAR POLÍTICAS PARA OUTRAS TABELAS IMPORTANTES
-- Milk Production
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS milk_production_select_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_insert_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_update_policy ON milk_production;
DROP POLICY IF EXISTS milk_production_delete_policy ON milk_production;

CREATE POLICY milk_production_select_policy ON milk_production
    FOR SELECT TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY milk_production_insert_policy ON milk_production
    FOR INSERT TO authenticated
    WITH CHECK (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY milk_production_update_policy ON milk_production
    FOR UPDATE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    )
    WITH CHECK (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY milk_production_delete_policy ON milk_production
    FOR DELETE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

-- Quality Tests
ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS quality_tests_select_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_insert_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_update_policy ON quality_tests;
DROP POLICY IF EXISTS quality_tests_delete_policy ON quality_tests;

CREATE POLICY quality_tests_select_policy ON quality_tests
    FOR SELECT TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY quality_tests_insert_policy ON quality_tests
    FOR INSERT TO authenticated
    WITH CHECK (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY quality_tests_update_policy ON quality_tests
    FOR UPDATE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    )
    WITH CHECK (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

CREATE POLICY quality_tests_delete_policy ON quality_tests
    FOR DELETE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
    );

-- 6. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename IN ('users', 'secondary_accounts', 'milk_production', 'quality_tests')
ORDER BY tablename, policyname;

-- 7. TESTAR CONSULTAS CRÍTICAS
-- Estas consultas devem funcionar agora
SELECT COUNT(*) as total_users FROM users WHERE id = auth.uid();
SELECT farm_id FROM users WHERE email = 'devnasc@gmail.com' LIMIT 1;
SELECT COUNT(*) as total_production FROM milk_production WHERE farm_id IN (SELECT farm_id FROM users WHERE id = auth.uid()); 