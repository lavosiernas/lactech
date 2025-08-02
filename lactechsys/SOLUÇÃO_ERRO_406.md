# SOLUÇÃO PARA ERRO 406 (Not Acceptable)

## 🚨 PROBLEMA IDENTIFICADO

O erro `406 (Not Acceptable)` na consulta da tabela `secondary_accounts` indica que:

1. **A tabela `secondary_accounts` não existe** no banco de dados
2. **A tabela existe mas não está acessível** devido a problemas de RLS
3. **Problemas de permissões** na tabela

## 🔧 SOLUÇÃO PASSO A PASSO

### PASSO 1: Criar a Tabela Secondary_Accounts

Execute o script `fix_secondary_accounts_table.sql` no Supabase SQL Editor:

```sql
-- Executar no Supabase SQL Editor
-- Arquivo: fix_secondary_accounts_table.sql
```

Este script irá:
- ✅ Verificar se a tabela existe
- ✅ Criar a tabela se não existir
- ✅ Configurar RLS corretamente
- ✅ Criar políticas de acesso

### PASSO 2: Incluir as Funções Melhoradas

Adicione o script `include_secondary_account_fix.js` nas páginas:

```html
<!-- Adicionar no head das páginas veterinario.html e funcionario.html -->
<script src="include_secondary_account_fix.js"></script>
```

### PASSO 3: Testar a Funcionalidade

No console do navegador, execute:

```javascript
// Testar se a tabela está acessível
diagnoseSecondaryAccountIssue()

// Testar a verificação de conta secundária
testSecondaryAccountCheck()
```

## 📋 VERIFICAÇÕES NECESSÁRIAS

### 1. Verificar se a Tabela Existe
```sql
-- No Supabase SQL Editor
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'secondary_accounts';
```

### 2. Verificar RLS da Tabela
```sql
-- No Supabase SQL Editor
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'secondary_accounts'
AND schemaname = 'public';
```

### 3. Verificar Políticas RLS
```sql
-- No Supabase SQL Editor
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'secondary_accounts'
AND schemaname = 'public';
```

## 🧪 TESTES PARA VERIFICAR

### Teste 1: Verificar Acesso à Tabela
```javascript
// No console do navegador
supabase
  .from('secondary_accounts')
  .select('id')
  .limit(1)
  .then(({ data, error }) => {
    if (error) {
      console.error('❌ Erro:', error);
    } else {
      console.log('✅ Tabela acessível:', data);
    }
  });
```

### Teste 2: Verificar Relação de Conta Secundária
```javascript
// No console do navegador
const { data: { user } } = await supabase.auth.getUser();
if (user) {
  supabase
    .from('secondary_accounts')
    .select('primary_account_id')
    .eq('secondary_account_id', user.id)
    .single()
    .then(({ data, error }) => {
      if (error) {
        console.log('📋 Erro:', error);
        if (error.code === 'PGRST116') {
          console.log('✅ Usuário não é conta secundária');
        }
      } else {
        console.log('✅ Usuário é conta secundária:', data);
      }
    });
}
```

## 🎯 RESULTADO ESPERADO

Após aplicar as correções:

### ✅ Sucesso:
```
✅ Tabela secondary_accounts acessível
✅ Usuário não é conta secundária (nenhuma relação encontrada)
✅ Perfil configurado para conta principal
```

### ❌ Se ainda houver erro:
```
❌ Erro na tabela secondary_accounts: [detalhes do erro]
💡 Execute o script fix_secondary_accounts_table.sql no Supabase
```

## 🔍 LOGS IMPORTANTES

### Logs de Sucesso:
```
🔍 Verificando se é conta secundária...
👤 Usuário autenticado: [email]
✅ Tabela secondary_accounts acessível
✅ Usuário não é conta secundária (nenhuma relação encontrada)
✅ Perfil configurado para conta principal
```

### Logs de Erro:
```
⚠️ Tabela secondary_accounts não existe ou não está acessível
📋 Erro: [detalhes do erro]
❌ Erro ao verificar relação: [detalhes do erro]
```

## 🚨 TROUBLESHOOTING

### Se o erro 406 persistir:

1. **Verificar se a tabela foi criada:**
   ```sql
   SELECT * FROM information_schema.tables 
   WHERE table_name = 'secondary_accounts';
   ```

2. **Verificar RLS:**
   ```sql
   SELECT rowsecurity FROM pg_tables 
   WHERE tablename = 'secondary_accounts';
   ```

3. **Verificar políticas:**
   ```sql
   SELECT policyname FROM pg_policies 
   WHERE tablename = 'secondary_accounts';
   ```

4. **Recriar a tabela se necessário:**
   ```sql
   DROP TABLE IF EXISTS secondary_accounts;
   -- Executar novamente o script fix_secondary_accounts_table.sql
   ```

## ✅ STATUS DA SOLUÇÃO

- ✅ **Script SQL criado** para verificar/criar tabela
- ✅ **Funções JavaScript melhoradas** com melhor tratamento de erro
- ✅ **Script de inclusão** para aplicar as melhorias
- ✅ **Testes de diagnóstico** para verificar funcionalidade
- ✅ **Documentação completa** explicando a solução

## 🎉 RESULTADO FINAL

Após aplicar todas as correções:

1. **Tabela `secondary_accounts`** será criada e configurada corretamente
2. **Erro 406** será resolvido
3. **Funções de conta secundária** funcionarão corretamente
4. **Interface se adaptará** baseado no tipo de conta

O sistema estará totalmente funcional para contas principais e secundárias. 