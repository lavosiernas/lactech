# 🔄 Guia de Migração - LacTech Database

## Visão Geral

Este guia detalha como migrar do banco de dados problemático atual para o novo esquema completo e seguro do LacTech.

## ⚠️ Problemas do Banco Atual

O erro `new row violates row-level security policy for table "farms"` ocorre devido a:

1. **Políticas RLS mal configuradas**: Políticas duplicadas e conflitantes
2. **Falta de políticas adequadas**: Algumas operações não têm políticas definidas
3. **Problemas de autenticação**: Funções executadas sem contexto de usuário adequado
4. **Esquema incompleto**: Faltam tabelas, índices e funções essenciais

## 🆕 Benefícios do Novo Banco

### ✅ Segurança Aprimorada
- **RLS Completo**: Políticas bem definidas para todas as tabelas
- **Isolamento por Fazenda**: Cada fazenda vê apenas seus dados
- **Controle de Acesso**: Permissões baseadas em funções (roles)
- **Autenticação Integrada**: Uso correto do `auth.uid()` do Supabase

### ✅ Performance Otimizada
- **Índices Estratégicos**: Consultas mais rápidas
- **Triggers Automáticos**: Campos `updated_at` atualizados automaticamente
- **Consultas Otimizadas**: Funções RPC eficientes

### ✅ Funcionalidades Completas
- **Todas as Tabelas**: Esquema completo do sistema
- **Funções RPC**: Operações complexas simplificadas
- **Validações**: Constraints e checks de integridade
- **Auditoria**: Rastreamento de mudanças

## 📋 Passo a Passo da Migração

### 1. Backup dos Dados Atuais (Opcional)

```sql
-- Se você tem dados importantes, faça backup primeiro
CREATE TABLE backup_farms AS SELECT * FROM farms;
CREATE TABLE backup_users AS SELECT * FROM users;
-- Repita para outras tabelas com dados importantes
```

### 2. Remover Esquema Antigo

```sql
-- Desabilitar RLS temporariamente
ALTER TABLE farms DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
-- Repita para outras tabelas

-- Remover políticas antigas
DROP POLICY IF EXISTS insert_farms_policy ON farms;
DROP POLICY IF EXISTS insert_farms_first_access ON farms;
-- Remova outras políticas problemáticas

-- Remover funções antigas (se necessário)
DROP FUNCTION IF EXISTS check_farm_exists(text, text);
DROP FUNCTION IF EXISTS check_user_exists(text);
DROP FUNCTION IF EXISTS create_initial_farm(text, text, text, text, text, integer, numeric, numeric, text, text, text);
DROP FUNCTION IF EXISTS create_initial_user(uuid, uuid, text, text, text, text);
DROP FUNCTION IF EXISTS complete_farm_setup(uuid);

-- Remover tabelas (CUIDADO: isso apaga todos os dados)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS user_access_requests CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS treatments CASCADE;
DROP TABLE IF EXISTS animal_health_records CASCADE;
DROP TABLE IF EXISTS quality_tests CASCADE;
DROP TABLE IF EXISTS milk_production CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS farms CASCADE;
```

### 3. Aplicar Novo Esquema

```sql
-- Execute o arquivo complete_database_schema.sql
-- No Supabase Dashboard:
-- 1. Vá para SQL Editor
-- 2. Cole o conteúdo do arquivo complete_database_schema.sql
-- 3. Execute o script
```

### 4. Verificar Instalação

```sql
-- Verificar se todas as tabelas foram criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar se RLS está habilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Verificar funções RPC
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%farm%' OR routine_name LIKE '%user%'
ORDER BY routine_name;
```

### 5. Atualizar Configuração do Frontend

1. **Substitua o arquivo de configuração atual**:
   - Remova ou renomeie `config.js`
   - Use `supabase_config_updated.js`

2. **Atualize as referências nos arquivos HTML**:
   ```html
   <!-- Substitua -->
   <script src="config.js"></script>
   
   <!-- Por -->
   <script src="supabase_config_updated.js"></script>
   ```

3. **Atualize as chamadas de função**:
   ```javascript
   // Antes
   const result = await supabase.rpc('create_initial_farm', params);
   
   // Agora
   const result = await LacTechAPI.registerUserAndFarm(farmData, adminData);
   ```

### 6. Testar Funcionalidades

#### Teste 1: Primeiro Acesso
```javascript
// Teste de criação de fazenda e usuário
const farmData = {
    name: "Fazenda Teste",
    owner_name: "João Silva",
    cnpj: "12.345.678/0001-90",
    city: "São Paulo",
    state: "SP",
    animal_count: 50,
    daily_production: 500
};

const adminData = {
    name: "João Silva",
    email: "joao@teste.com",
    password: "senha123",
    role: "proprietario",
    whatsapp: "11999999999"
};

const result = await LacTechAPI.registerUserAndFarm(farmData, adminData);
console.log(result);
```

#### Teste 2: Login
```javascript
const loginResult = await LacTechAPI.loginUser("joao@teste.com", "senha123");
console.log(loginResult);
```

#### Teste 3: Obter Perfil
```javascript
const profile = await LacTechAPI.getUserProfile();
console.log(profile);
```

#### Teste 4: Registrar Produção
```javascript
const production = {
    date: "2024-01-15",
    shift: "manha",
    volume: 250.5,
    temperature: 4.2,
    observations: "Produção normal"
};

const result = await LacTechAPI.registerMilkProduction(production);
console.log(result);
```

## 🔧 Solução de Problemas

### Erro: "relation does not exist"
**Causa**: Tabela não foi criada corretamente
**Solução**: Execute novamente o script `complete_database_schema.sql`

### Erro: "function does not exist"
**Causa**: Função RPC não foi criada
**Solução**: Verifique se todas as funções foram criadas no script

### Erro: "permission denied for table"
**Causa**: Política RLS bloqueando acesso
**Solução**: Verifique se o usuário está autenticado e tem permissão

### Erro: "new row violates row-level security policy"
**Causa**: Tentativa de inserir dados sem permissão adequada
**Solução**: Use as funções RPC fornecidas em vez de INSERT direto

## 📞 Suporte

Se encontrar problemas durante a migração:

1. **Verifique os logs**: Console do navegador e logs do Supabase
2. **Teste passo a passo**: Execute cada etapa individualmente
3. **Valide dados**: Certifique-se de que os dados estão no formato correto
4. **Consulte a documentação**: `DATABASE_SETUP_GUIDE.md` tem informações detalhadas

## 🎯 Próximos Passos

Após a migração bem-sucedida:

1. **Teste todas as funcionalidades** do sistema
2. **Treine a equipe** nas novas funcionalidades
3. **Configure backups automáticos** no Supabase
4. **Monitore performance** e otimize conforme necessário
5. **Implemente funcionalidades adicionais** conforme demanda

---

**✅ Com este novo banco, o erro de RLS será completamente resolvido e você terá uma base sólida e segura para o sistema LacTech!**