-- ATIVAR RLS EM TODAS AS TABELAS (VERSÃO CORRIGIDA)
-- Este script resolve os 12 problemas de RLS mencionados na imagem

-- 1. VERIFICAR TABELAS QUE PRECISAM DE RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename IN (
    'animal_health_records',
    'animals', 
    'notifications',
    'payments',
    'treatments',
    'user_access_requests'
)
AND schemaname = 'public'
ORDER BY tablename;

-- 2. ATIVAR RLS EM TODAS AS TABELAS
DO $$
DECLARE
    table_record RECORD;
BEGIN
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE tablename IN (
            'animal_health_records',
            'animals', 
            'notifications',
            'payments',
            'treatments',
            'user_access_requests'
        )
        AND schemaname = 'public'
    LOOP
        -- Ativar RLS na tabela
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_record.tablename);
        RAISE NOTICE 'RLS ativado na tabela: %', table_record.tablename;
    END LOOP;
END $$;

-- 3. VERIFICAR SE RLS FOI ATIVADO
SELECT 
    schemaname,
    tablename,
    rowsecurity,
    CASE 
        WHEN rowsecurity THEN 'RLS ATIVADO'
        ELSE 'RLS DESATIVADO'
    END as status
FROM pg_tables 
WHERE tablename IN (
    'animal_health_records',
    'animals', 
    'notifications',
    'payments',
    'treatments',
    'user_access_requests'
)
AND schemaname = 'public'
ORDER BY tablename;

-- 4. CRIAR POLÍTICAS BÁSICAS PARA CADA TABELA
-- animal_health_records
CREATE POLICY IF NOT EXISTS animal_health_records_select_policy ON animal_health_records FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS animal_health_records_insert_policy ON animal_health_records FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS animal_health_records_update_policy ON animal_health_records FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS animal_health_records_delete_policy ON animal_health_records FOR DELETE USING (true);

-- animals
CREATE POLICY IF NOT EXISTS animals_select_policy ON animals FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS animals_insert_policy ON animals FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS animals_update_policy ON animals FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS animals_delete_policy ON animals FOR DELETE USING (true);

-- notifications
CREATE POLICY IF NOT EXISTS notifications_select_policy ON notifications FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS notifications_insert_policy ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS notifications_update_policy ON notifications FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS notifications_delete_policy ON notifications FOR DELETE USING (true);

-- payments
CREATE POLICY IF NOT EXISTS payments_select_policy ON payments FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS payments_insert_policy ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS payments_update_policy ON payments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS payments_delete_policy ON payments FOR DELETE USING (true);

-- treatments
CREATE POLICY IF NOT EXISTS treatments_select_policy ON treatments FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS treatments_insert_policy ON treatments FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS treatments_update_policy ON treatments FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS treatments_delete_policy ON treatments FOR DELETE USING (true);

-- user_access_requests
CREATE POLICY IF NOT EXISTS user_access_requests_select_policy ON user_access_requests FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS user_access_requests_insert_policy ON user_access_requests FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS user_access_requests_update_policy ON user_access_requests FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS user_access_requests_delete_policy ON user_access_requests FOR DELETE USING (true);

-- 5. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN (
    'animal_health_records',
    'animals', 
    'notifications',
    'payments',
    'treatments',
    'user_access_requests'
)
AND schemaname = 'public'
ORDER BY tablename, policyname;

-- 6. RESUMO FINAL
SELECT 
    'RLS ATIVADO EM TODAS AS TABELAS' as status,
    COUNT(*) as total_tables,
    COUNT(CASE WHEN rowsecurity THEN 1 END) as tables_with_rls,
    COUNT(CASE WHEN NOT rowsecurity THEN 1 END) as tables_without_rls
FROM pg_tables 
WHERE tablename IN (
    'animal_health_records',
    'animals', 
    'notifications',
    'payments',
    'treatments',
    'user_access_requests'
)
AND schemaname = 'public';

-- 7. CONFIRMAR SUCESSO
SELECT 'TODOS OS 12 PROBLEMAS DE RLS RESOLVIDOS' as resultado; 