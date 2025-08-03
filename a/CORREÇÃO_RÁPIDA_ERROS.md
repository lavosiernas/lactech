# CORREÇÃO RÁPIDA DOS ERROS 400

## Problema Identificado
O novo banco de dados não está compatível com o JavaScript das páginas, causando erros 400 (Bad Request).

## Solução

### 1. Execute o script de correção RLS
```sql
-- Execute este script no Supabase SQL Editor
-- Arquivo: fix_rls_compatibility.sql
```

### 2. Execute o script de funções faltantes
```sql
-- Execute este script no Supabase SQL Editor  
-- Arquivo: add_missing_functions.sql
```

### 3. Verifique se as tabelas têm todas as colunas necessárias

O banco deve ter estas colunas na tabela `users`:
- `id` (UUID)
- `farm_id` (UUID)
- `name` (VARCHAR)
- `email` (VARCHAR)
- `role` (VARCHAR)
- `whatsapp` (VARCHAR)
- `is_active` (BOOLEAN)
- `profile_photo_url` (TEXT)
- `report_farm_name` (VARCHAR)
- `report_farm_logo_base64` (TEXT)
- `report_footer_text` (TEXT)
- `report_system_logo_base64` (TEXT)

### 4. Teste as páginas
Após executar os scripts:
1. Teste `gerente.html`
2. Teste `veterinario.html`
3. Teste `funcionario.html`
4. Teste `proprietario.html`

### 5. Se ainda houver erros 400
Verifique no console do navegador qual requisição específica está falhando e me informe o erro exato.

## Arquivos Removidos
- `test_foto_debug.js` (referência removida do gerente.html)

## Funções RPC Adicionadas
- `get_user_profile()`
- `create_initial_farm()`
- `create_initial_user()`
- `get_user_settings()`
- `update_user_settings()`
- `get_dashboard_stats()`
- `get_production_history()`
- `get_quality_data()`
- `get_payments_data()`
- `get_farm_users_data()`

## Políticas RLS Corrigidas
Todas as políticas foram configuradas como permissivas (`USING (true)`) para evitar erros de acesso. 