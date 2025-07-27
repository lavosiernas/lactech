-- Resolver conflito create_initial_user
DROP FUNCTION IF EXISTS create_initial_user(integer, integer, character varying, character varying, character varying, character varying);
DROP FUNCTION IF EXISTS create_initial_user(uuid, uuid, text, text, text, text);

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