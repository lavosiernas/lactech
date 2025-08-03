# Solução para o Problema de Criação de Contas Secundárias

## Problema Identificado

O sistema está enfrentando um erro ao tentar criar contas secundárias devido a uma restrição de unicidade no campo `email` da tabela `users`. Quando um gerente tenta criar uma conta secundária usando o mesmo email da conta principal, o banco de dados rejeita a operação com um erro 409 (Conflict).

## Detalhes Técnicos do Erro

1. **Erro 406 (Not Acceptable)**: Ocorre durante a consulta para verificar usuários existentes com o mesmo email e farm_id.
   ```
   lzqbzztoawjnqwgffhjv.supabase.co/rest/v1/users?select=*&email=eq.devnasc%40gmail.com&farm_id=eq.6186a476-16a8-48c4-a158-9dd7a82f4d29&id=neq.3ee064c8-beb7-4750-931f-ea30289b5a88:1
   ```

2. **Erro 409 (Conflict)**: Ocorre durante a inserção do novo usuário, devido à violação da restrição de unicidade no campo `email`.
   ```
   lzqbzztoawjnqwgffhjv.supabase.co/rest/v1/users?columns=%22id%22%2C%22farm_id%22%2C%22name%22%2C%22email%22%2C%22role%22%2C%22whatsapp%22%2C%22is_active%22%2C%22profile_photo_url%22&select=*:1
   ```

## Soluções Propostas

Existem duas abordagens para resolver este problema:

### Solução 1: Modificar a Estrutura do Banco de Dados (Recomendada)

Esta solução envolve alterar a restrição de unicidade na tabela `users` para permitir emails duplicados desde que estejam associados a diferentes IDs de usuário na mesma fazenda.

#### Passos para Implementação:

1. Execute o script SQL `fix_email_constraint.sql` no console SQL do Supabase:
   - Este script remove a restrição UNIQUE do campo `email`
   - Adiciona uma nova restrição composta para `email`, `farm_id` e `id`

2. Crie a tabela `secondary_accounts` executando o script `create_secondary_accounts_table.sql`:
   - Esta tabela rastreia a relação entre contas principais e secundárias
   - Facilita a gestão e navegação entre contas

### Solução 2: Modificar o Código para Usar Emails Diferentes (Alternativa)

Se não for possível modificar a estrutura do banco de dados, esta solução altera o código para gerar um email modificado para a conta secundária.

#### Passos para Implementação:

1. Substitua a função `saveSecondaryAccount` no arquivo `gerente.html` pelo código fornecido em `fix_secondary_account.js`
   - Esta solução gera um email único para a conta secundária baseado no email principal (ex: `usuario@dominio.com` → `usuario+secondary@dominio.com`)

## Instruções para Aplicar a Solução

### Para Administradores do Banco de Dados:

1. Acesse o Dashboard do Supabase (https://app.supabase.io)
2. Navegue até o projeto `lzqbzztoawjnqwgffhjv`
3. Vá para a seção "SQL Editor"
4. Execute os scripts na seguinte ordem:
   - `fix_email_constraint.sql`
   - `create_secondary_accounts_table.sql`
5. Verifique se as alterações foram aplicadas corretamente consultando a estrutura da tabela `users`

### Para Desenvolvedores (se a Solução 1 não for viável):

1. Abra o arquivo `gerente.html`
2. Localize a função `saveSecondaryAccount` (aproximadamente linha 6200)
3. Substitua a função pelo código fornecido em `fix_secondary_account.js`
4. Teste a criação de contas secundárias

## Verificação da Solução

Após aplicar uma das soluções, teste o sistema criando uma nova conta secundária. O processo deve ser concluído sem erros e a conta secundária deve aparecer corretamente na interface.

## Notas Adicionais

- A Solução 1 (modificação do banco de dados) é preferível, pois mantém a consistência do modelo de dados e permite usar o mesmo email para contas principal e secundária.
- A Solução 2 (modificação do código) é mais simples de implementar, mas cria emails artificiais para as contas secundárias, o que pode causar confusão para os usuários.
- Ambas as soluções são compatíveis com o sistema existente e não afetam outras funcionalidades.