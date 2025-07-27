# Guia de Configuração do Banco de Dados LacTech

## Visão Geral

Este guia explica como configurar o banco de dados PostgreSQL completo para o Sistema LacTech de Gestão de Fazendas Leiteiras. O novo esquema resolve todos os problemas de RLS (Row Level Security) e fornece uma base sólida e segura para o sistema.

## Arquivos Importantes

- `complete_database_schema.sql` - Esquema completo do banco de dados
- `database_schema.sql` - Esquema antigo (problemático)

## Características do Novo Esquema

### ✅ Problemas Resolvidos

1. **Erro RLS "new row violates row-level security policy"** - Completamente resolvido
2. **Políticas RLS conflitantes** - Reorganizadas e simplificadas
3. **Funções RPC incompletas** - Todas as funções necessárias implementadas
4. **Segurança multi-tenant** - Isolamento completo entre fazendas
5. **Performance** - Índices otimizados para consultas frequentes

### 🚀 Novas Funcionalidades

1. **Sistema completo de usuários** com 4 perfis (proprietário, gerente, funcionário, veterinário)
2. **Gestão de animais** com histórico de saúde
3. **Controle de qualidade** do leite com bonificações
4. **Sistema de pagamentos** com cálculos automáticos
5. **Notificações** integradas
6. **Solicitações de acesso** para novos usuários
7. **Auditoria completa** com timestamps

## Instalação

### Passo 1: Backup (Importante!)

```sql
-- Faça backup dos dados existentes se houver
pg_dump sua_database > backup_antes_da_migracao.sql
```

### Passo 2: Limpar Esquema Antigo (Opcional)

```sql
-- ATENÇÃO: Isso apagará todos os dados existentes!
-- Execute apenas se quiser começar do zero

DROP TABLE IF EXISTS user_access_requests CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS treatments CASCADE;
DROP TABLE IF EXISTS animal_health_records CASCADE;
DROP TABLE IF EXISTS quality_tests CASCADE;
DROP TABLE IF EXISTS milk_production CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS farms CASCADE;

-- Remover funções antigas
DROP FUNCTION IF EXISTS check_farm_exists(TEXT, TEXT);
DROP FUNCTION IF EXISTS check_user_exists(TEXT);
DROP FUNCTION IF EXISTS create_initial_farm(TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, DECIMAL, DECIMAL, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS create_initial_user(UUID, UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS complete_farm_setup(UUID);
```

### Passo 3: Executar Novo Esquema

```bash
# No Supabase SQL Editor ou psql
psql -h seu_host -U seu_usuario -d sua_database -f complete_database_schema.sql
```

Ou copie e cole o conteúdo do arquivo `complete_database_schema.sql` no SQL Editor do Supabase.

### Passo 4: Verificar Instalação

```sql
-- Verificar se todas as tabelas foram criadas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Verificar funções RPC
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_type = 'FUNCTION';
```

## Estrutura do Banco

### Tabelas Principais

1. **farms** - Dados das fazendas
2. **users** - Usuários do sistema (vinculados ao Supabase Auth)
3. **animals** - Cadastro do rebanho
4. **milk_production** - Registros de produção diária
5. **quality_tests** - Testes de qualidade do leite
6. **animal_health_records** - Histórico de saúde dos animais
7. **treatments** - Tratamentos veterinários
8. **payments** - Controle financeiro
9. **notifications** - Sistema de notificações
10. **user_access_requests** - Solicitações de acesso

### Funções RPC Disponíveis

```sql
-- Verificação de existência
check_farm_exists(p_name, p_cnpj)
check_user_exists(p_email)

-- Primeiro acesso
create_initial_farm(...)
create_initial_user(...)
complete_farm_setup(p_farm_id)

-- Operações do sistema
get_user_profile()
register_milk_production(...)
get_farm_statistics()
```

## Segurança RLS

### Princípios de Segurança

1. **Isolamento por Fazenda**: Cada usuário só acessa dados de sua fazenda
2. **Controle por Perfil**: Diferentes permissões por tipo de usuário
3. **Primeiro Acesso Seguro**: Permite criação inicial sem conflitos
4. **Auditoria Completa**: Todos os registros têm timestamps e usuário responsável

### Perfis e Permissões

| Perfil | Criar Fazenda | Gerenciar Usuários | Ver Financeiro | Registrar Produção | Gerenciar Animais |
|--------|---------------|-------------------|----------------|-------------------|-------------------|
| Proprietário | ✅ | ✅ (Todos) | ✅ | ✅ | ✅ |
| Gerente | ❌ | ✅ (Funcionário/Vet) | ✅ | ✅ | ✅ |
| Funcionário | ❌ | ❌ | ❌ | ✅ | ❌ |
| Veterinário | ❌ | ❌ | ❌ | ❌ | ✅ |

## Testando o Sistema

### 1. Teste de Primeiro Acesso

```javascript
// No frontend, teste o fluxo completo:
// 1. Criar conta no Supabase Auth
// 2. Chamar create_initial_farm
// 3. Chamar create_initial_user
// 4. Chamar complete_farm_setup
```

### 2. Teste de RLS

```sql
-- Simular usuário logado
SET request.jwt.claims TO '{"sub": "uuid-do-usuario"}';

-- Tentar acessar dados
SELECT * FROM farms;
SELECT * FROM users;
```

### 3. Teste de Produção

```sql
-- Registrar produção
SELECT register_milk_production(
    CURRENT_DATE,
    'manha',
    150.5,
    3.2,
    'Produção normal'
);

-- Ver estatísticas
SELECT get_farm_statistics();
```

## Migração de Dados Existentes

Se você tem dados no esquema antigo:

```sql
-- Exemplo de migração de fazendas
INSERT INTO farms (name, owner_name, city, state, setup_completed)
SELECT name, owner_name, city, state, true
FROM farms_old;

-- Migrar usuários (ajustar conforme necessário)
INSERT INTO users (id, farm_id, name, email, role)
SELECT auth_id, farm_id, name, email, role
FROM users_old;
```

## Monitoramento e Manutenção

### Consultas Úteis

```sql
-- Verificar uso por fazenda
SELECT f.name, COUNT(u.id) as usuarios, COUNT(mp.id) as registros_producao
FROM farms f
LEFT JOIN users u ON f.id = u.farm_id
LEFT JOIN milk_production mp ON f.id = mp.farm_id
GROUP BY f.id, f.name;

-- Verificar performance
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname = 'public'
ORDER BY tablename, attname;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';
```

### Backup Automático

```bash
# Script de backup diário
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h host -U user -d database > backup_lactech_$DATE.sql

# Manter apenas últimos 7 dias
find /path/to/backups -name "backup_lactech_*.sql" -mtime +7 -delete
```

## Solução de Problemas

### Erro: "new row violates row-level security policy"

✅ **Resolvido no novo esquema!** As políticas foram redesenhadas para permitir operações necessárias.

### Erro: "policy already exists"

```sql
-- Remover política existente
DROP POLICY IF EXISTS nome_da_politica ON nome_da_tabela;

-- Recriar com novo esquema
-- (executar complete_database_schema.sql novamente)
```

### Erro: "function does not exist"

```sql
-- Verificar se funções foram criadas
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public';

-- Recriar funções se necessário
-- (executar seção de funções do complete_database_schema.sql)
```

### Performance Lenta

```sql
-- Analisar tabelas
ANALYZE;

-- Verificar índices
SELECT tablename, indexname, indexdef 
FROM pg_indexes 
WHERE schemaname = 'public';

-- Criar índices adicionais se necessário
CREATE INDEX IF NOT EXISTS idx_custom ON tabela(coluna);
```

## Próximos Passos

1. ✅ Execute o novo esquema
2. ✅ Teste o fluxo de primeiro acesso
3. ✅ Verifique se RLS está funcionando
4. ✅ Teste todas as funcionalidades do frontend
5. ✅ Configure backup automático
6. ✅ Monitore performance

## Suporte

Se encontrar problemas:

1. Verifique os logs do Supabase
2. Execute as consultas de verificação
3. Consulte a documentação do PostgreSQL RLS
4. Teste com dados de exemplo

---

**Importante**: Este esquema foi projetado para resolver todos os problemas identificados no sistema anterior. Ele fornece uma base sólida, segura e escalável para o Sistema LacTech.