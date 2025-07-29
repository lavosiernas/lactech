-- =====================================================
-- HABILITAR RLS NAS OUTRAS TABELAS
-- =====================================================
-- Este script habilita RLS nas tabelas que já têm políticas criadas

-- 1. HABILITAR RLS NA TABELA FARMS
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
SELECT 'RLS habilitado na tabela farms' as status;

-- 2. HABILITAR RLS NA TABELA MILK_PRODUCTION
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
SELECT 'RLS habilitado na tabela milk_production' as status;

-- 3. HABILITAR RLS NA TABELA QUALITY_TESTS
ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
SELECT 'RLS habilitado na tabela quality_tests' as status;

-- 4. HABILITAR RLS NA TABELA PAYMENTS
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
SELECT 'RLS habilitado na tabela payments' as status;

-- 5. VERIFICAR STATUS DE TODAS AS TABELAS
SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN 'HABILITADO'
        ELSE 'DESABILITADO'
    END as rls_status
FROM pg_tables 
WHERE tablename IN ('users', 'farms', 'milk_production', 'quality_tests', 'payments')
ORDER BY tablename;

-- 6. VERIFICAR POLÍTICAS EXISTENTES
SELECT 
    tablename,
    policyname,
    cmd as operacao
FROM pg_policies 
WHERE tablename IN ('farms', 'milk_production', 'quality_tests', 'payments')
ORDER BY tablename, cmd;

COMMIT;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- Todas as tabelas devem ter RLS HABILITADO
-- As políticas já existem, então não haverá problemas
-- O sistema deve continuar funcionando normalmente
-- =====================================================