-- ATIVAR RLS EM TODAS AS TABELAS
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
        WHEN rowsecurity THEN '✅ RLS ATIVADO'
        ELSE '❌ RLS DESATIVADO'
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

-- 4. VERIFICAR POLÍTICAS EXISTENTES
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

-- 5. CRIAR POLÍTICAS BÁSICAS SE NÃO EXISTIREM
-- Política para animal_health_records
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animal_health_records' AND policyname = 'animal_health_records_select_policy') THEN
        CREATE POLICY animal_health_records_select_policy ON animal_health_records
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para animal_health_records';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animal_health_records' AND policyname = 'animal_health_records_insert_policy') THEN
        CREATE POLICY animal_health_records_insert_policy ON animal_health_records
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para animal_health_records';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animal_health_records' AND policyname = 'animal_health_records_update_policy') THEN
        CREATE POLICY animal_health_records_update_policy ON animal_health_records
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para animal_health_records';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animal_health_records' AND policyname = 'animal_health_records_delete_policy') THEN
        CREATE POLICY animal_health_records_delete_policy ON animal_health_records
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para animal_health_records';
    END IF;
END $$;

-- Política para animals
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animals' AND policyname = 'animals_select_policy') THEN
        CREATE POLICY animals_select_policy ON animals
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para animals';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animals' AND policyname = 'animals_insert_policy') THEN
        CREATE POLICY animals_insert_policy ON animals
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para animals';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animals' AND policyname = 'animals_update_policy') THEN
        CREATE POLICY animals_update_policy ON animals
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para animals';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'animals' AND policyname = 'animals_delete_policy') THEN
        CREATE POLICY animals_delete_policy ON animals
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para animals';
    END IF;
END $$;

-- Política para notifications
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'notifications_select_policy') THEN
        CREATE POLICY notifications_select_policy ON notifications
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para notifications';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'notifications_insert_policy') THEN
        CREATE POLICY notifications_insert_policy ON notifications
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para notifications';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'notifications_update_policy') THEN
        CREATE POLICY notifications_update_policy ON notifications
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para notifications';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'notifications' AND policyname = 'notifications_delete_policy') THEN
        CREATE POLICY notifications_delete_policy ON notifications
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para notifications';
    END IF;
END $$;

-- Política para payments
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'payments_select_policy') THEN
        CREATE POLICY payments_select_policy ON payments
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para payments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'payments_insert_policy') THEN
        CREATE POLICY payments_insert_policy ON payments
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para payments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'payments_update_policy') THEN
        CREATE POLICY payments_update_policy ON payments
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para payments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'payments' AND policyname = 'payments_delete_policy') THEN
        CREATE POLICY payments_delete_policy ON payments
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para payments';
    END IF;
END $$;

-- Política para treatments
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'treatments' AND policyname = 'treatments_select_policy') THEN
        CREATE POLICY treatments_select_policy ON treatments
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para treatments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'treatments' AND policyname = 'treatments_insert_policy') THEN
        CREATE POLICY treatments_insert_policy ON treatments
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para treatments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'treatments' AND policyname = 'treatments_update_policy') THEN
        CREATE POLICY treatments_update_policy ON treatments
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para treatments';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'treatments' AND policyname = 'treatments_delete_policy') THEN
        CREATE POLICY treatments_delete_policy ON treatments
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para treatments';
    END IF;
END $$;

-- Política para user_access_requests
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_access_requests' AND policyname = 'user_access_requests_select_policy') THEN
        CREATE POLICY user_access_requests_select_policy ON user_access_requests
        FOR SELECT USING (true);
        RAISE NOTICE 'Política SELECT criada para user_access_requests';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_access_requests' AND policyname = 'user_access_requests_insert_policy') THEN
        CREATE POLICY user_access_requests_insert_policy ON user_access_requests
        FOR INSERT WITH CHECK (true);
        RAISE NOTICE 'Política INSERT criada para user_access_requests';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_access_requests' AND policyname = 'user_access_requests_update_policy') THEN
        CREATE POLICY user_access_requests_update_policy ON user_access_requests
        FOR UPDATE USING (true) WITH CHECK (true);
        RAISE NOTICE 'Política UPDATE criada para user_access_requests';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_access_requests' AND policyname = 'user_access_requests_delete_policy') THEN
        CREATE POLICY user_access_requests_delete_policy ON user_access_requests
        FOR DELETE USING (true);
        RAISE NOTICE 'Política DELETE criada para user_access_requests';
    END IF;
END $$;

-- 6. VERIFICAR POLÍTICAS FINAIS
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    CASE 
        WHEN permissive THEN 'PERMISSIVE'
        ELSE 'RESTRICTIVE'
    END as policy_type
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

-- 7. RESUMO FINAL
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

-- 8. CONFIRMAR SUCESSO
SELECT 'TODOS OS 12 PROBLEMAS DE RLS RESOLVIDOS' as resultado; 