-- =====================================================
-- VERIFICAR ESTRUTURA REAL DO BANCO
-- =====================================================

-- Verificar estrutura da tabela users
SELECT 'USERS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Verificar estrutura da tabela farms
SELECT 'FARMS TABLE STRUCTURE:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'farms' 
ORDER BY ordinal_position;

-- Verificar dados existentes
SELECT 'USERS DATA SAMPLE:' as info;
SELECT id, name, email, role, farm_id, is_active 
FROM users 
LIMIT 5;

SELECT 'FARMS DATA SAMPLE:' as info;
SELECT id, name, city, state 
FROM farms 
LIMIT 5; 