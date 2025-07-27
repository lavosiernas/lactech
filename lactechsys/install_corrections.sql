-- =====================================================
-- SCRIPT DE INSTALAÇÃO COMPLETA DAS CORREÇÕES LACTECH
-- Execute este script no SQL Editor do Supabase para aplicar todas as correções
-- =====================================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE IF EXISTS farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS animals DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS milk_production DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quality_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS animal_health_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS treatments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_access_requests DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS farms_insert_policy ON farms;
DROP POLICY IF EXISTS farms_select_policy ON farms;
DROP POLICY IF EXISTS farms_update_policy ON farms;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS animals_policy ON animals;
DROP POLICY IF EXISTS milk_production_policy ON milk_production;
DROP POLICY IF EXISTS quality_tests_policy ON quality_tests;
DROP POLICY IF EXISTS animal_health_records_policy ON animal_health_records;
DROP POLICY IF EXISTS treatments_policy ON treatments;
DROP POLICY IF EXISTS payments_policy ON payments;
DROP POLICY IF EXISTS notifications_policy ON notifications;
DROP POLICY IF EXISTS user_access_requests_policy ON user_access_requests;

-- 3. REMOVER FUNÇÕES EXISTENTES PARA EVITAR CONFLITOS
DROP FUNCTION IF EXISTS check_farm_exists(character varying, character varying);
DROP FUNCTION IF EXISTS check_farm_exists(text, text);
DROP FUNCTION IF EXISTS check_farm_exists(text);
DROP FUNCTION IF EXISTS check_user_exists(character varying);
DROP FUNCTION IF EXISTS check_user_exists(text);
DROP FUNCTION IF EXISTS create_initial_farm(character varying, character varying, character varying, text, character varying, character varying, character varying, character varying, numeric, integer, numeric);
DROP FUNCTION IF EXISTS create_initial_farm(text, text, text, text, text, integer, numeric, numeric, text, text, text);
DROP FUNCTION IF EXISTS create_initial_user(integer, integer, character varying, character varying, character varying, character varying);
DROP FUNCTION IF EXISTS create_initial_user(uuid, uuid, text, text, text, text);
DROP FUNCTION IF EXISTS complete_farm_setup(uuid);
DROP FUNCTION IF EXISTS get_user_profile();
DROP FUNCTION IF EXISTS register_milk_production(date, text, numeric, numeric, text);
DROP FUNCTION IF EXISTS get_farm_statistics();

-- 4. CRIAR TABELAS SE NÃO EXISTIREM
CREATE TABLE IF NOT EXISTS farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    animal_count INTEGER DEFAULT 0,
    daily_production DECIMAL(10,2) DEFAULT 0,
    total_area_hectares DECIMAL(10,2),
    setup_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT farms_name_unique UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('proprietario', 'gerente', 'funcionario', 'veterinario')),
    whatsapp VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    identification VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    breed VARCHAR(100),
    birth_date DATE,
    weight DECIMAL(6,2),
    health_status VARCHAR(20) DEFAULT 'saudavel' CHECK (health_status IN ('saudavel', 'doente', 'tratamento', 'quarentena')),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT animals_farm_identification_unique UNIQUE (farm_id, identification)
);

CREATE TABLE IF NOT EXISTS milk_production (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    production_date DATE NOT NULL,
    shift VARCHAR(10) NOT NULL CHECK (shift IN ('manha', 'tarde', 'noite')),
    volume_liters DECIMAL(8,2) NOT NULL CHECK (volume_liters >= 0),
    temperature DECIMAL(4,2),
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT milk_production_unique_entry UNIQUE (farm_id, production_date, shift)
);

CREATE TABLE IF NOT EXISTS quality_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    test_date DATE NOT NULL,
    fat_percentage DECIMAL(4,2),
    protein_percentage DECIMAL(4,2),
    somatic_cell_count INTEGER,
    total_bacterial_count INTEGER,
    quality_grade VARCHAR(10) CHECK (quality_grade IN ('A', 'B', 'C', 'D')),
    bonus_percentage DECIMAL(4,2) DEFAULT 0,
    laboratory VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS animal_health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    veterinarian_id UUID REFERENCES users(id),
    record_date DATE NOT NULL,
    diagnosis TEXT,
    symptoms TEXT,
    severity VARCHAR(10) CHECK (severity IN ('leve', 'moderada', 'grave', 'critica')),
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'resolvido', 'cronico')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS treatments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    health_record_id UUID NOT NULL REFERENCES animal_health_records(id) ON DELETE CASCADE,
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    veterinarian_id UUID NOT NULL REFERENCES users(id),
    medication_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    administration_route VARCHAR(50),
    treatment_start_date DATE NOT NULL,
    treatment_end_date DATE,
    withdrawal_period_days INTEGER DEFAULT 0,
    cost DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    reference_period_start DATE NOT NULL,
    reference_period_end DATE NOT NULL,
    volume_liters DECIMAL(10,2) NOT NULL,
    base_price_per_liter DECIMAL(6,4) NOT NULL,
    quality_bonus DECIMAL(10,2) DEFAULT 0,
    deductions DECIMAL(10,2) DEFAULT 0,
    gross_amount DECIMAL(12,2) NOT NULL,
    net_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pendente' CHECK (payment_status IN ('pendente', 'pago', 'cancelado')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('info', 'warning', 'error', 'success')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_access_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    requester_name VARCHAR(255) NOT NULL,
    requester_email VARCHAR(255) NOT NULL,
    requester_phone VARCHAR(20),
    requested_role VARCHAR(20) NOT NULL CHECK (requested_role IN ('gerente', 'funcionario', 'veterinario')),
    message TEXT,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'aprovado', 'rejeitado')),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. CRIAR ÍNDICES
CREATE UNIQUE INDEX IF NOT EXISTS idx_farms_cnpj_unique ON farms(cnpj) 
WHERE cnpj IS NOT NULL AND cnpj != '';

CREATE INDEX IF NOT EXISTS idx_users_farm_id ON users(farm_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_animals_farm_id ON animals(farm_id);
CREATE INDEX IF NOT EXISTS idx_milk_production_farm_date ON milk_production(farm_id, production_date);
CREATE INDEX IF NOT EXISTS idx_quality_tests_farm_date ON quality_tests(farm_id, test_date);
CREATE INDEX IF NOT EXISTS idx_health_records_animal_id ON animal_health_records(animal_id);
CREATE INDEX IF NOT EXISTS idx_treatments_health_record ON treatments(health_record_id);
CREATE INDEX IF NOT EXISTS idx_payments_farm_date ON payments(farm_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read);

-- 6. CRIAR TRIGGERS
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_farms_updated_at BEFORE UPDATE ON farms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_animals_updated_at BEFORE UPDATE ON animals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. CRIAR FUNÇÕES RPC
CREATE OR REPLACE FUNCTION check_farm_exists(p_name TEXT, p_cnpj TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM farms 
        WHERE name = p_name 
        OR (p_cnpj IS NOT NULL AND p_cnpj != '' AND cnpj = p_cnpj)
    );
END;
$$;

CREATE OR REPLACE FUNCTION check_user_exists(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM users WHERE email = p_email);
END;
$$;

CREATE OR REPLACE FUNCTION create_initial_farm(
    p_name TEXT,
    p_owner_name TEXT,
    p_city TEXT,
    p_state TEXT,
    p_cnpj TEXT DEFAULT '',
    p_animal_count INTEGER DEFAULT 0,
    p_daily_production DECIMAL DEFAULT 0,
    p_total_area_hectares DECIMAL DEFAULT NULL,
    p_phone TEXT DEFAULT '',
    p_email TEXT DEFAULT '',
    p_address TEXT DEFAULT ''
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    farm_id UUID;
BEGIN
    INSERT INTO farms (
        name, owner_name, cnpj, city, state, animal_count, 
        daily_production, total_area_hectares, phone, email, address
    ) VALUES (
        p_name, p_owner_name, NULLIF(p_cnpj, ''), p_city, p_state, 
        p_animal_count, p_daily_production, p_total_area_hectares, 
        NULLIF(p_phone, ''), NULLIF(p_email, ''), NULLIF(p_address, '')
    ) RETURNING id INTO farm_id;
    
    RETURN farm_id;
END;
$$;

CREATE OR REPLACE FUNCTION create_initial_user(
    p_user_id UUID,
    p_farm_id UUID,
    p_name TEXT,
    p_email TEXT,
    p_role TEXT,
    p_whatsapp TEXT DEFAULT ''
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO users (id, farm_id, name, email, role, whatsapp)
    VALUES (p_user_id, p_farm_id, p_name, p_email, p_role, NULLIF(p_whatsapp, ''));
END;
$$;

CREATE OR REPLACE FUNCTION complete_farm_setup(p_farm_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE farms SET setup_completed = true WHERE id = p_farm_id;
END;
$$;

CREATE OR REPLACE FUNCTION get_user_profile()
RETURNS TABLE(
    user_id UUID,
    farm_id UUID,
    farm_name VARCHAR(255),
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    user_role VARCHAR(20),
    user_whatsapp VARCHAR(20)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.farm_id,
        f.name,
        u.name,
        u.email,
        u.role,
        u.whatsapp
    FROM users u
    JOIN farms f ON u.farm_id = f.id
    WHERE u.id = auth.uid();
END;
$$;

CREATE OR REPLACE FUNCTION register_milk_production(
    p_production_date DATE,
    p_shift TEXT,
    p_volume_liters DECIMAL,
    p_temperature DECIMAL DEFAULT NULL,
    p_observations TEXT DEFAULT ''
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    production_id UUID;
    user_farm_id UUID;
BEGIN
    SELECT farm_id INTO user_farm_id FROM users WHERE id = auth.uid();
    
    IF user_farm_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou não associado a uma fazenda';
    END IF;
    
    INSERT INTO milk_production (
        farm_id, user_id, production_date, shift, volume_liters, temperature, observations
    ) VALUES (
        user_farm_id, auth.uid(), p_production_date, p_shift, p_volume_liters, p_temperature, NULLIF(p_observations, '')
    )
    ON CONFLICT (farm_id, production_date, shift)
    DO UPDATE SET
        volume_liters = EXCLUDED.volume_liters,
        temperature = EXCLUDED.temperature,
        observations = EXCLUDED.observations,
        user_id = auth.uid()
    RETURNING id INTO production_id;
    
    RETURN production_id;
END;
$$;

CREATE OR REPLACE FUNCTION get_farm_statistics()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_farm_id UUID;
    stats JSON;
BEGIN
    SELECT farm_id INTO user_farm_id FROM users WHERE id = auth.uid();
    
    IF user_farm_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou não associado a uma fazenda';
    END IF;
    
    SELECT json_build_object(
        'total_animals', COALESCE((SELECT COUNT(*) FROM animals WHERE farm_id = user_farm_id AND is_active = true), 0),
        'today_production', COALESCE((SELECT SUM(volume_liters) FROM milk_production WHERE farm_id = user_farm_id AND production_date = CURRENT_DATE), 0),
        'week_average', COALESCE((SELECT AVG(daily_total.volume) FROM (
            SELECT SUM(volume_liters) as volume 
            FROM milk_production 
            WHERE farm_id = user_farm_id 
            AND production_date >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY production_date
        ) daily_total), 0),
        'month_total', COALESCE((SELECT SUM(volume_liters) FROM milk_production WHERE farm_id = user_farm_id AND production_date >= DATE_TRUNC('month', CURRENT_DATE)), 0),
        'active_users', COALESCE((SELECT COUNT(*) FROM users WHERE farm_id = user_farm_id AND is_active = true), 0)
    ) INTO stats;
    
    RETURN stats;
END;
$$;

-- 8. CRIAR POLÍTICAS RLS PERMISSIVAS
CREATE POLICY "Authenticated users can access farms" ON farms
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access users" ON users
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access animals" ON animals
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access milk_production" ON milk_production
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access quality_tests" ON quality_tests
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access animal_health_records" ON animal_health_records
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access treatments" ON treatments
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access payments" ON payments
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access notifications" ON notifications
FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can access user_access_requests" ON user_access_requests
FOR ALL USING (auth.role() = 'authenticated');

-- 9. REABILITAR RLS
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE milk_production ENABLE ROW LEVEL SECURITY;
ALTER TABLE quality_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE animal_health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_access_requests ENABLE ROW LEVEL SECURITY;

-- 10. CONFIGURAR STORAGE
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can manage profile photos" ON storage.objects;

CREATE POLICY "Authenticated users can manage profile photos" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-photos' AND 
  auth.role() = 'authenticated'
);

-- 11. VERIFICAR INSTALAÇÃO
SELECT 'Instalação completa das correções LacTech finalizada!' as status;

-- Verificar tabelas criadas
SELECT 'Tabelas criadas:' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar funções criadas
SELECT 'Funções RPC criadas:' as info;
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- Verificar políticas RLS
SELECT 'Políticas RLS aplicadas:' as info;
SELECT tablename, policyname FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

COMMIT; 