-- =====================================================
-- SOLUÇÃO EMERGENCIAL: DESABILITAR RLS TEMPORARIAMENTE
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Desabilitar RLS em todas as tabelas principais
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production DISABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;

-- NOTA: storage.objects requer permissões especiais de super usuário
-- Se precisar desabilitar RLS no storage, contate o suporte do Supabase

-- Verificar status do RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename IN ('users', 'farms', 'milk_production', 'quality_tests', 'payments')
ORDER BY tablename;

-- =====================================================
-- IMPORTANTE: ISSO É TEMPORÁRIO!
-- =====================================================
-- Após o sistema voltar a funcionar, você deve:
-- 1. Reabilitar o RLS: ALTER TABLE [tabela] ENABLE ROW LEVEL SECURITY;
-- 2. Aplicar políticas corretas
-- 3. Testar gradualmente
-- =====================================================

-- Para reabilitar depois (NÃO EXECUTE AGORA):
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE payments ENABLE ROW LEVEL SECURITY;