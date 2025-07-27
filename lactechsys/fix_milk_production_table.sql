-- Script para corrigir a tabela milk_production no Supabase
-- Execute este script no SQL Editor do Supabase

-- Primeiro, vamos verificar se a tabela existe e remover se necessário
DROP TABLE IF EXISTS milk_production CASCADE;

-- Criar a tabela milk_production com a estrutura correta
CREATE TABLE milk_production (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    production_date DATE NOT NULL,
    shift VARCHAR(10) NOT NULL CHECK (shift IN ('manha', 'tarde', 'noite')),
    volume_liters DECIMAL(8,2) NOT NULL CHECK (volume_liters >= 0),
    temperature DECIMAL(4,2),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT milk_production_unique_entry UNIQUE (farm_id, production_date, shift)
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_milk_production_farm_date ON milk_production(farm_id, production_date);
CREATE INDEX IF NOT EXISTS idx_milk_production_user_date ON milk_production(user_id, production_date);
CREATE INDEX IF NOT EXISTS idx_milk_production_date ON milk_production(production_date);

-- Habilitar RLS
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
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
        AND user_id = auth.uid()
    );

CREATE POLICY milk_production_update_policy ON milk_production
    FOR UPDATE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
        AND user_id = auth.uid()
    )
    WITH CHECK (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
        AND user_id = auth.uid()
    );

CREATE POLICY milk_production_delete_policy ON milk_production
    FOR DELETE TO authenticated
    USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE id = auth.uid()
        )
        AND user_id = auth.uid()
    );

-- Criar trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_milk_production_updated_at 
    BEFORE UPDATE ON milk_production
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Inserir alguns dados de exemplo (opcional)
-- Descomente as linhas abaixo se quiser dados de teste
/*
INSERT INTO milk_production (farm_id, user_id, production_date, shift, volume_liters, observations)
SELECT 
    u.farm_id,
    u.id,
    CURRENT_DATE,
    'manha',
    25.5,
    'Registro de teste'
FROM users u
WHERE u.role = 'funcionario'
LIMIT 1;
*/

COMMIT;