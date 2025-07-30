-- Script para corrigir a restrição de email único na tabela users
-- Este script remove a restrição UNIQUE do campo email e adiciona uma restrição composta
-- para email e farm_id, permitindo contas secundárias com o mesmo email em uma fazenda

-- 1. Primeiro, identificar o nome da restrição de unicidade do email
DO $$
DECLARE
    constraint_name text;
BEGIN
    SELECT conname INTO constraint_name
    FROM pg_constraint
    WHERE conrelid = 'users'::regclass
    AND contype = 'u'
    AND array_position(conkey, (
        SELECT attnum
        FROM pg_attribute
        WHERE attrelid = 'users'::regclass
        AND attname = 'email'
    )) IS NOT NULL;
    
    -- 2. Remover a restrição de unicidade do email
    IF constraint_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE users DROP CONSTRAINT ' || constraint_name;
        RAISE NOTICE 'Restrição % removida com sucesso', constraint_name;
    ELSE
        RAISE NOTICE 'Restrição de unicidade para email não encontrada';
    END IF;
    
    -- 3. Adicionar uma restrição composta para email e farm_id
    -- Isso permite emails duplicados desde que estejam em fazendas diferentes
    -- ou sejam contas secundárias na mesma fazenda
    BEGIN
        ALTER TABLE users ADD CONSTRAINT users_email_farm_id_unique 
        UNIQUE (email, farm_id, id);
        RAISE NOTICE 'Nova restrição composta adicionada com sucesso';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'A restrição composta já existe';
    END;
END $$;

-- 4. Verificar se a alteração foi aplicada corretamente
SELECT conname, contype, conkey
FROM pg_constraint
WHERE conrelid = 'users'::regclass
AND contype = 'u';

-- Nota: Este script deve ser executado pelo administrador do banco de dados
-- no console SQL do Supabase ou através de uma conexão direta ao banco de dados.