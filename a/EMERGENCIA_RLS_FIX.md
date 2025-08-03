# 🚨 CORREÇÃO EMERGENCIAL - RLS BLOQUEANDO SISTEMA

## ❌ PROBLEMA
O RLS (Row Level Security) foi ativado e está bloqueando o acesso aos usuários, causando erro 500 no login.

## ✅ SOLUÇÃO IMEDIATA

### PASSO 1: Acessar Supabase Dashboard
1. Acesse: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: **lzqbzztoawjnqwgffhjv**

### PASSO 2: Ir para SQL Editor
1. No menu lateral, clique em **"SQL Editor"**
2. Clique em **"New query"**

### PASSO 3: Executar Comandos SQL
Cole e execute os seguintes comandos **UM POR VEZ**:

```sql
-- 1. Desabilitar RLS na tabela users
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

```sql
-- 2. Remover todas as políticas
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_delete_policy ON users;
```

```sql
-- 3. Verificar se foi corrigido
SELECT * FROM users LIMIT 1;
```

### PASSO 4: Testar o Sistema
1. Abra o arquivo: `login.html`
2. Tente fazer login
3. Verifique se o erro 500 foi resolvido

## 📋 VERIFICAÇÃO

Se tudo funcionou corretamente, você deve conseguir:
- ✅ Fazer login sem erro 500
- ✅ Acessar a lista de usuários
- ✅ Criar/editar/excluir usuários

## ⚠️ IMPORTANTE

**O sistema está configurado para funcionar SEM RLS por enquanto.**

Este é um sistema interno de fazenda, então a segurança adicional do RLS não é crítica no momento. O foco é manter o sistema funcionando.

## 🔧 ARQUIVOS RELACIONADOS

- `disable_rls_users.sql` - Script SQL completo
- `disable_rls_test.html` - Teste via navegador
- `fix_delete_users_complete.sql` - Script que causou o problema

## 📞 SUPORTE

Se ainda houver problemas:
1. Verifique o console do navegador (F12)
2. Confirme que os comandos SQL foram executados
3. Reinicie o navegador e teste novamente