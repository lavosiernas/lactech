-- CORRIGIR TABELA TREATMENTS
-- Este script adiciona a coluna status que está faltando

-- 1. VERIFICAR ESTRUTURA ATUAL DA TABELA
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'treatments'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNA STATUS SE NÃO EXISTIR
DO $$
BEGIN
    -- Verificar se a coluna status já existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'treatments' AND column_name = 'status'
    ) THEN
        -- Adicionar coluna status
        ALTER TABLE treatments ADD COLUMN status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'suspended'));
        
        RAISE NOTICE 'Coluna status adicionada à tabela treatments';
    ELSE
        RAISE NOTICE 'Coluna status já existe na tabela treatments';
    END IF;
END $$;

-- 3. VERIFICAR SE A COLUNA FOI ADICIONADA
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'treatments' AND column_name = 'status';

-- 4. ATUALIZAR TRATAMENTOS EXISTENTES SEM STATUS
UPDATE treatments 
SET status = 'active' 
WHERE status IS NULL;

-- 5. VERIFICAR DADOS ATUAIS
SELECT 
    id,
    medication_name,
    treatment_start_date,
    treatment_end_date,
    status,
    created_at
FROM treatments 
LIMIT 5;

-- 6. CRIAR ÍNDICE PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_treatments_status ON treatments(status);
CREATE INDEX IF NOT EXISTS idx_treatments_veterinarian ON treatments(veterinarian_id);

-- 7. VERIFICAR SE A TABELA ESTÁ FUNCIONAL
SELECT 
    COUNT(*) as total_treatments,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_treatments,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_treatments
FROM treatments;

-- 8. TESTAR CONSULTA QUE ESTAVA FALHANDO
SELECT id, status 
FROM treatments 
WHERE status = 'active';

-- 9. CONFIRMAR CORREÇÃO
SELECT 'TABELA TREATMENTS CORRIGIDA - COLUNA STATUS ADICIONADA' as status; 