-- Criar tabela para configurações da fazenda
CREATE TABLE IF NOT EXISTS farm_settings (
    id SERIAL PRIMARY KEY,
    farm_id INTEGER NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    farm_name VARCHAR(255) NOT NULL DEFAULT 'Sistema Leiteiro',
    farm_logo TEXT, -- Base64 encoded image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(farm_id)
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE farm_settings ENABLE ROW LEVEL SECURITY;

-- Política para permitir que usuários vejam apenas configurações da sua fazenda
CREATE POLICY "Users can view their farm settings" ON farm_settings
    FOR SELECT USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE auth.uid() = id
        )
    );

-- Política para permitir que usuários atualizem apenas configurações da sua fazenda
CREATE POLICY "Users can update their farm settings" ON farm_settings
    FOR ALL USING (
        farm_id IN (
            SELECT farm_id FROM users WHERE auth.uid() = id
        )
    );

-- Inserir configurações padrão para fazendas existentes
INSERT INTO farm_settings (farm_id, farm_name)
SELECT DISTINCT f.id, 'Sistema Leiteiro'
FROM farms f
WHERE NOT EXISTS (
    SELECT 1 FROM farm_settings fs WHERE fs.farm_id = f.id
);

-- Comentários
COMMENT ON TABLE farm_settings IS 'Configurações personalizadas para cada fazenda';
COMMENT ON COLUMN farm_settings.farm_name IS 'Nome personalizado da fazenda para relatórios';
COMMENT ON COLUMN farm_settings.farm_logo IS 'Logo da fazenda em formato Base64 para relatórios';