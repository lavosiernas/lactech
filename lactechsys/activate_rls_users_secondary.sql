-- =====================================================
-- ATIVAR RLS NAS TABELAS USERS E SECONDARY_ACCOUNTS
-- =====================================================

-- 1. ATIVAR RLS NA TABELA USERS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 2. CRIAR POLÍTICAS PERMISSIVAS PARA USERS
CREATE POLICY users_select_policy ON users FOR SELECT USING (true);
CREATE POLICY users_insert_policy ON users FOR INSERT WITH CHECK (true);
CREATE POLICY users_update_policy ON users FOR UPDATE USING (true);
CREATE POLICY users_delete_policy ON users FOR DELETE USING (true);

-- 3. ATIVAR RLS NA TABELA SECONDARY_ACCOUNTS
ALTER TABLE secondary_accounts ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS PERMISSIVAS PARA SECONDARY_ACCOUNTS
CREATE POLICY secondary_accounts_select_policy ON secondary_accounts FOR SELECT USING (true);
CREATE POLICY secondary_accounts_insert_policy ON secondary_accounts FOR INSERT WITH CHECK (true);
CREATE POLICY secondary_accounts_update_policy ON secondary_accounts FOR UPDATE USING (true);
CREATE POLICY secondary_accounts_delete_policy ON secondary_accounts FOR DELETE USING (true);

-- =====================================================
-- MENSAGEM DE CONFIRMAÇÃO
-- =====================================================
SELECT 'RLS ATIVADO COM SUCESSO! Tabelas users e secondary_accounts agora têm RLS ativo com políticas permissivas.' as resultado; 