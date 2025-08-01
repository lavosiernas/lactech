# Guia para Implementação de Contas Secundárias sem Alterar Políticas RLS

## Problema

O sistema apresenta dois problemas relacionados às contas secundárias:

1. **Erro 409 (Conflict)**: Ocorre ao tentar criar uma conta secundária com o mesmo email de uma conta existente, devido à restrição `UNIQUE` na coluna `email` da tabela `users`.

2. **Erro 406 (Not Acceptable)**: Ocorre quando uma conta secundária tenta acessar o sistema, devido às políticas RLS (Row Level Security) que restringem o acesso apenas ao próprio perfil do usuário.

## Solução Implementada

A solução implementada no arquivo `consertar_contas_secundarias.sql` resolve ambos os problemas **sem alterar as políticas RLS existentes** na tabela `users`. Esta solução:

1. **Modifica a restrição de email único**: Remove a restrição `UNIQUE` simples do campo `email` e adiciona uma restrição composta para `email`, `farm_id` e `id`. Isso permite que existam emails duplicados desde que tenham IDs diferentes ou estejam em fazendas diferentes.

2. **Cria a tabela `secondary_accounts`**: Esta tabela rastreia a relação entre contas principais e secundárias, permitindo que o sistema identifique quais contas são secundárias e a qual conta principal estão vinculadas.

## Como Aplicar a Solução

### Passo 1: Executar o Script SQL

1. Acesse o Dashboard do Supabase (https://app.supabase.io)
2. Selecione o projeto: lzqbzztoawjnqwgffhjv
3. No menu lateral, clique em "SQL Editor"
4. Clique em "New query"
5. Cole o conteúdo do arquivo `consertar_contas_secundarias.sql` e execute

### Passo 2: Verificar a Implementação

Após executar o script, verifique se:

1. A restrição de email foi modificada corretamente
2. A tabela `secondary_accounts` foi criada
3. As políticas RLS para a tabela `secondary_accounts` foram criadas

## Como Funciona

### Criação de Contas Secundárias

Quando uma conta secundária é criada:

1. Um novo registro é inserido na tabela `users` com o mesmo email da conta principal, mas com um ID diferente
2. Um registro é inserido na tabela `secondary_accounts` vinculando a conta secundária à conta principal

### Acesso ao Sistema

Quando um usuário tenta acessar o sistema:

1. As políticas RLS existentes na tabela `users` continuam funcionando normalmente
2. A tabela `secondary_accounts` permite identificar quais contas são secundárias e a qual conta principal estão vinculadas

## Vantagens desta Solução

1. **Não altera as políticas RLS existentes**: Mantém a segurança do sistema intacta
2. **Solução robusta**: Implementa a solução recomendada pelos desenvolvedores do sistema
3. **Compatibilidade**: Funciona com o código existente sem necessidade de alterações adicionais

## Observações Importantes

- Esta solução não requer a desativação das políticas RLS existentes
- A solução é compatível com o código existente que gerencia contas secundárias
- A implementação é segura e não compromete a integridade dos dados

## Suporte

Em caso de dúvidas ou problemas, consulte a documentação adicional ou entre em contato com o suporte técnico.