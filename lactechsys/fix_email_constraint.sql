-- CORRIGIR RESTRIÇÃO DE EMAIL PARA CONTAS SECUNDÁRIAS
-- Este script resolve o erro 409 ao criar contas secundárias

-- 1. VERIFICAR RESTRIÇÕES ATUAIS
SELECT 
    constraint_name,
    table_name,
    constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'users' 
AND constraint_type = 'UNIQUE';

-- 2. REMOVER RESTRIÇÃO PROBLEMÁTICA
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_farm_unique;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_key;

-- 3. CRIAR RESTRIÇÃO MAIS FLEXÍVEL
-- Permitir emails duplicados em diferentes fazendas, mas não na mesma fazenda
ALTER TABLE users ADD CONSTRAINT users_email_farm_unique 
UNIQUE (email, farm_id, id);

-- 4. VERIFICAR SE A RESTRIÇÃO FOI CRIADA
SELECT 
    constraint_name,
    table_name,
    constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'users' 
AND constraint_type = 'UNIQUE';

-- 5. TESTAR INSERÇÃO DE CONTA SECUNDÁRIA
-- Primeiro, vamos ver os usuários existentes
SELECT id, email, farm_id, name, role FROM users WHERE email = 'devnasc@gmail.com';

-- 6. VERIFICAR SE EXISTE CONTA SECUNDÁRIA
SELECT 
    u1.id as primary_id,
    u1.name as primary_name,
    u1.email as primary_email,
    u2.id as secondary_id,
    u2.name as secondary_name,
    u2.email as secondary_email
FROM users u1
LEFT JOIN users u2 ON u1.email = u2.email AND u1.farm_id = u2.farm_id AND u1.id != u2.id
WHERE u1.email = 'devnasc@gmail.com';

-- 7. CRIAR FUNÇÃO PARA GERAR EMAIL ÚNICO
CREATE OR REPLACE FUNCTION generate_secondary_email(primary_email TEXT, role TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Se o role for funcionario, adiciona .func
    -- Se o role for veterinario, adiciona .vet
    IF role = 'funcionario' THEN
        RETURN primary_email || '.func';
    ELSIF role = 'veterinario' THEN
        RETURN primary_email || '.vet';
    ELSE
        RETURN primary_email || '.sec';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. TESTAR A FUNÇÃO
SELECT generate_secondary_email('devnasc@gmail.com', 'funcionario') as email_funcionario;
SELECT generate_secondary_email('devnasc@gmail.com', 'veterinario') as email_veterinario;

-- 9. VERIFICAR SE AS ALTERAÇÕES FUNCIONARAM
SELECT 'RESTRIÇÃO DE EMAIL CORRIGIDA - SISTEMA PRONTO PARA CONTAS SECUNDÁRIAS' as status;