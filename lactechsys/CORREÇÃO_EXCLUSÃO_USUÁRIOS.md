# Correção: Problema na Exclusão de Usuários

## Problema Identificado
O sistema não consegue excluir usuários porque **não existe uma política RLS (Row Level Security) para DELETE na tabela `users`**.

## Causa
O Supabase possui RLS habilitado na tabela `users`, mas apenas as políticas para INSERT, SELECT e UPDATE foram criadas. A política para DELETE está ausente, impedindo qualquer exclusão de usuários.

## Solução

### 1. Executar o Script de Correção
Execute o arquivo `fix_users_delete_policy.sql` no seu banco de dados Supabase:

```sql
-- Adicionar política RLS para DELETE na tabela users
CREATE POLICY users_delete_policy ON users
    FOR DELETE TO authenticated
    USING (
        -- Permite que proprietários e gerentes excluam usuários da mesma fazenda
        farm_id IN (
            SELECT farm_id FROM users 
            WHERE id = auth.uid() 
            AND role IN ('proprietario', 'gerente')
        )
        -- Impede que o usuário exclua a si mesmo
        AND id != auth.uid()
    );
```

### 2. Como Aplicar a Correção

#### Opção A: Via Dashboard do Supabase
1. Acesse o Dashboard do Supabase
2. Vá para "SQL Editor"
3. Cole o código SQL acima
4. Execute o script

#### Opção B: Via psql ou outro cliente SQL
1. Conecte-se ao banco de dados
2. Execute o script `fix_users_delete_policy.sql`

### 3. Verificação
Após executar o script, verifique se a política foi criada:

```sql
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'users' AND policyname = 'users_delete_policy';
```

### 4. Teste
Após aplicar a correção:
1. Faça login como proprietário ou gerente
2. Tente excluir o usuário problemático
3. Verifique os logs no console do navegador (F12) para confirmar que a exclusão funcionou

## Regras da Política Criada
- ✅ Proprietários podem excluir usuários da mesma fazenda
- ✅ Gerentes podem excluir usuários da mesma fazenda  
- ❌ Funcionários NÃO podem excluir usuários
- ❌ Usuários NÃO podem excluir a si mesmos
- ❌ Usuários NÃO podem excluir usuários de outras fazendas

## Logs de Debug Adicionados
Também foram adicionados logs de debug na função `confirmDeleteUser()` para facilitar futuras investigações. Verifique o console do navegador (F12) ao tentar excluir usuários.

---
**Data da Correção:** $(Get-Date -Format "dd/MM/yyyy HH:mm")
**Arquivos Modificados:**
- `gerente.html` (logs de debug)
- `fix_users_delete_policy.sql` (nova política RLS)
- `CORREÇÃO_EXCLUSÃO_USUÁRIOS.md` (este guia)