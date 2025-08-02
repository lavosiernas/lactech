-- CORREÇÃO COMPLETA DA TABELA TREATMENTS
-- Este script adiciona todas as colunas que estão faltando

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'treatments'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNAS FALTANTES
DO $$
BEGIN
    -- Adicionar coluna status se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'status'
    ) THEN
        ALTER TABLE treatments ADD COLUMN status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'suspended'));
        RAISE NOTICE 'Coluna status adicionada';
    END IF;
    
    -- Adicionar coluna treatment_type se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'treatment_type'
    ) THEN
        ALTER TABLE treatments ADD COLUMN treatment_type VARCHAR(50) DEFAULT 'medication' CHECK (treatment_type IN ('medication', 'vaccination', 'surgery', 'examination', 'other'));
        RAISE NOTICE 'Coluna treatment_type adicionada';
    END IF;
    
    -- Adicionar coluna animal_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'animal_id'
    ) THEN
        ALTER TABLE treatments ADD COLUMN animal_id UUID REFERENCES animals(id);
        RAISE NOTICE 'Coluna animal_id adicionada';
    END IF;
    
    -- Adicionar coluna medication se não existir (além de medication_name)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'medication'
    ) THEN
        ALTER TABLE treatments ADD COLUMN medication VARCHAR(255);
        RAISE NOTICE 'Coluna medication adicionada';
    END IF;
    
    -- Adicionar coluna start_date se não existir (além de treatment_start_date)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'start_date'
    ) THEN
        ALTER TABLE treatments ADD COLUMN start_date DATE;
        RAISE NOTICE 'Coluna start_date adicionada';
    END IF;
    
    -- Adicionar coluna end_date se não existir (além de treatment_end_date)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'end_date'
    ) THEN
        ALTER TABLE treatments ADD COLUMN end_date DATE;
        RAISE NOTICE 'Coluna end_date adicionada';
    END IF;
    
END $$;

-- 3. SINCRONIZAR DADOS ENTRE COLUNAS DUPLICADAS
UPDATE treatments 
SET 
    medication = medication_name,
    start_date = treatment_start_date,
    end_date = treatment_end_date
WHERE 
    (medication IS NULL AND medication_name IS NOT NULL) OR
    (start_date IS NULL AND treatment_start_date IS NOT NULL) OR
    (end_date IS NULL AND treatment_end_date IS NOT NULL);

-- 4. ATUALIZAR TRATAMENTOS SEM STATUS
UPDATE treatments 
SET status = 'active' 
WHERE status IS NULL;

-- 5. ATUALIZAR TRATAMENTOS SEM TIPO
UPDATE treatments 
SET treatment_type = 'medication' 
WHERE treatment_type IS NULL;

-- 6. VERIFICAR ESTRUTURA FINAL
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'treatments'
ORDER BY ordinal_position;

-- 7. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_treatments_status ON treatments(status);
CREATE INDEX IF NOT EXISTS idx_treatments_veterinarian ON treatments(veterinarian_id);
CREATE INDEX IF NOT EXISTS idx_treatments_animal ON treatments(animal_id);
CREATE INDEX IF NOT EXISTS idx_treatments_type ON treatments(treatment_type);
CREATE INDEX IF NOT EXISTS idx_treatments_dates ON treatments(start_date, end_date);

-- 8. TESTAR CONSULTAS QUE ESTAVAM FALHANDO
SELECT 'Teste 1 - Consulta por status:' as teste;
SELECT id, status FROM treatments WHERE status = 'active' LIMIT 5;

SELECT 'Teste 2 - Consulta por tipo:' as teste;
SELECT id, treatment_type FROM treatments WHERE treatment_type = 'vaccination' LIMIT 5;

SELECT 'Teste 3 - Consulta completa:' as teste;
SELECT 
    id,
    medication_name,
    treatment_type,
    status,
    start_date,
    end_date
FROM treatments 
LIMIT 5;

-- 9. ESTATÍSTICAS DA TABELA
SELECT 
    COUNT(*) as total_treatments,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_treatments,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_treatments,
    COUNT(CASE WHEN treatment_type = 'medication' THEN 1 END) as medication_treatments,
    COUNT(CASE WHEN treatment_type = 'vaccination' THEN 1 END) as vaccination_treatments
FROM treatments;

-- 10. CONFIRMAR CORREÇÃO
SELECT 'TABELA TREATMENTS COMPLETAMENTE CORRIGIDA' as status; 