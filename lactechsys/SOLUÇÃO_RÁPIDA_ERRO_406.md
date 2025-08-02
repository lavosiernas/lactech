# SOLUÇÃO RÁPIDA PARA ERRO 406

## 🚨 PROBLEMA
O erro 406 persiste porque a tabela `secondary_accounts` não existe no Supabase.

## ⚡ SOLUÇÃO RÁPIDA

### PASSO 1: Execute o Script SQL Simples
No Supabase SQL Editor, execute:
```sql
-- Arquivo: create_secondary_accounts_simple.sql
CREATE TABLE IF NOT EXISTS secondary_accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    primary_account_id UUID NOT NULL,
    secondary_account_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_secondary_accounts_primary ON secondary_accounts(primary_account_id);
CREATE INDEX IF NOT EXISTS idx_secondary_accounts_secondary ON secondary_accounts(secondary_account_id);

ALTER TABLE secondary_accounts DISABLE ROW LEVEL SECURITY;
```

### PASSO 2: Use a Versão Simples (RECOMENDADO)
Adicione esta linha no `<head>` das páginas `veterinario.html` e `funcionario.html`:

```html
<script src="simple_secondary_account_check.js"></script>
```

### PASSO 3: Teste
No console do navegador:
```javascript
// Testar verificação simples
testSimpleSecondaryAccountCheck()

// Diagnóstico completo
diagnoseSimpleSecondaryAccount()
```

## 🎯 VANTAGENS DA VERSÃO SIMPLES

✅ **Não depende da tabela `secondary_accounts`**
✅ **Funciona imediatamente**
✅ **Baseada no email do usuário**
✅ **Sem erros 406**

## 📋 COMO FUNCIONA

A versão simples detecta contas secundárias baseada no email:

- **Contas secundárias**: `user@domain.com.func`, `user@domain.com.vet`
- **Contas principais**: `user@domain.com` (sem sufixo)

## ✅ RESULTADO ESPERADO

```
🔍 Verificando se é conta secundária (método simples)...
👤 Usuário autenticado: devnasc@gmail.com
✅ Usuário não é conta secundária (email padrão)
✅ Perfil configurado para conta principal
```

## 🚀 IMPLEMENTAÇÃO RÁPIDA

1. **Execute o script SQL** no Supabase
2. **Adicione o script simples** nas páginas
3. **Teste no console** do navegador
4. **Pronto!** Erro 406 resolvido

## 🔧 SE AINDA HOUVER PROBLEMAS

Execute no console:
```javascript
// Verificar se o script foi carregado
console.log('Funções disponíveis:', {
    checkIfSecondaryAccount: typeof checkIfSecondaryAccount,
    manageProfileSections: typeof manageProfileSections,
    switchToPrimaryAccount: typeof switchToPrimaryAccount
});

// Testar diagnóstico
diagnoseSimpleSecondaryAccount();
```

## 🎉 RESULTADO FINAL

- ❌ **Erro 406 eliminado**
- ✅ **Interface funciona corretamente**
- ✅ **Contas principais e secundárias detectadas**
- ✅ **Seções do perfil gerenciadas automaticamente** 