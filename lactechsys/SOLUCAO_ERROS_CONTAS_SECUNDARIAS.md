# Solução para Erros de Contas Secundárias

## Problemas Identificados

Os seguintes erros foram identificados no sistema de contas secundárias:

1. **Erro 404**: Tabela `secondary_accounts` não encontrada ou políticas RLS bloqueando acesso
2. **Erro 406**: Políticas RLS na tabela `users` impedindo consultas necessárias
3. **Erro 409**: Conflito ao tentar criar usuários com dados duplicados
4. **Erro JavaScript**: `Cannot set properties of null (setting 'disabled')`

## Solução Completa

### Passo 1: Executar Script SQL

1. Acesse o **Supabase Dashboard**: https://app.supabase.io
2. Selecione o projeto: `lzqbzztoawjnqwgffhjv`
3. Vá para **SQL Editor**
4. Execute o script `fix_secondary_accounts_complete_corrigido.sql` (versão corrigida)

Este script irá:
- Criar a tabela `secondary_accounts` se não existir
- Corrigir as políticas RLS da tabela `users`
- Criar políticas RLS adequadas para `secondary_accounts`
- Remover restrições UNIQUE problemáticas do email
- Criar restrições compostas que permitem emails duplicados em diferentes fazendas

### Passo 2: Verificar Execução

Após executar o script, verifique se:

1. A tabela `secondary_accounts` foi criada
2. As políticas RLS foram aplicadas corretamente
3. Não há erros na execução do script

### Passo 3: Testar o Sistema

1. Acesse o painel do gerente
2. Vá para o perfil do usuário
3. Teste a funcionalidade de contas secundárias

## Código JavaScript Corrigido

O arquivo `gerente.html` já foi atualizado com as seguintes correções:

1. **Tratamento de erros melhorado**: Uso de `try-catch` em todas as operações
2. **Verificação de elementos DOM**: Verifica se os elementos existem antes de manipulá-los
3. **Uso de `maybeSingle()`**: Em vez de `single()` para evitar erros quando não há dados
4. **Fallback para métodos antigos**: Se a tabela `secondary_accounts` não estiver disponível

## Principais Mudanças

### 1. Função `loadSecondaryAccountData()`

```javascript
// Antes
const { data: secondaryAccountRelation, error: relationError } = await supabase
    .from('secondary_accounts')
    .select('secondary_account_id')
    .eq('primary_account_id', user.id)
    .single();

// Depois
let secondaryAccountRelation = null;
try {
    const { data: relationData, error: relationError } = await supabase
        .from('secondary_accounts')
        .select('secondary_account_id')
        .eq('primary_account_id', user.id)
        .maybeSingle();
        
    if (relationError) {
        console.error('Erro ao verificar relação de conta secundária:', relationError);
    } else {
        secondaryAccountRelation = relationData;
    }
} catch (error) {
    console.error('Erro ao acessar tabela secondary_accounts:', error);
}
```

### 2. Verificação de Elementos DOM

```javascript
// Antes
document.getElementById('secondaryAccountName').value = secondaryAccount.name;

// Depois
const nameField = document.getElementById('secondaryAccountName');
if (nameField) nameField.value = secondaryAccount.name;
```

### 3. Tratamento de Erros Melhorado

```javascript
// Antes
if (secondaryError && secondaryError.code !== 'PGRST116') {
    console.error('Erro ao verificar conta secundária:', secondaryError);
    return;
}

// Depois
if (secondaryError) {
    console.error('Erro ao verificar conta secundária:', secondaryError);
}
```

## Verificação de Funcionamento

Após aplicar as correções, o sistema deve:

1. ✅ Carregar dados de contas secundárias sem erros 404
2. ✅ Permitir consultas na tabela `users` sem erros 406
3. ✅ Criar contas secundárias sem conflitos 409
4. ✅ Manipular elementos DOM sem erros de null
5. ✅ Exibir notificações de sucesso/erro adequadas

## Troubleshooting

### Se ainda houver erros 404:

1. Verifique se a tabela `secondary_accounts` foi criada:
```sql
SELECT * FROM information_schema.tables WHERE table_name = 'secondary_accounts';
```

2. Verifique as políticas RLS:
```sql
SELECT * FROM pg_policies WHERE tablename = 'secondary_accounts';
```

### Se ainda houver erros 406:

1. Verifique as políticas RLS da tabela `users`:
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

2. Teste uma consulta simples:
```sql
SELECT * FROM users WHERE id = auth.uid();
```

### Se ainda houver erros 409:

1. Verifique as restrições da tabela `users`:
```sql
SELECT * FROM information_schema.table_constraints WHERE table_name = 'users';
```

2. Verifique se a restrição composta foi criada:
```sql
SELECT * FROM information_schema.table_constraints 
WHERE table_name = 'users' AND constraint_name = 'users_email_farm_unique';
```

## Contato

Se os problemas persistirem após aplicar estas correções, verifique:

1. Logs do console do navegador
2. Logs do Supabase
3. Políticas RLS ativas
4. Restrições de banco de dados

---

**Última atualização**: $(date)
**Versão**: 1.0
**Status**: ✅ Implementado 