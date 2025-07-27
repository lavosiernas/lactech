# Correção: Erro de Upload de Fotos de Perfil

## Problema Identificado
O sistema está apresentando erros 400 ao tentar fazer upload de fotos de perfil:
- `Failed to load resource: the server responded with a status of 400`
- `Storage upload error: Object`
- `Error uploading photo: Object`

## Causa Provável
O problema está relacionado às **políticas RLS (Row Level Security) do Supabase Storage** para o bucket `profile-photos`. As políticas podem estar muito restritivas ou conflitantes.

## Solução

### 1. Executar Script de Correção
Execute o arquivo `fix_profile_photo_upload_final.sql` no seu banco de dados Supabase:

1. Acesse o Dashboard do Supabase
2. Vá para "SQL Editor"
3. Cole e execute o conteúdo do arquivo `fix_profile_photo_upload_final.sql`

### 2. Verificações Após Execução

#### A. Verificar se o bucket foi criado:
```sql
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets 
WHERE id = 'profile-photos';
```

#### B. Verificar se as políticas foram aplicadas:
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
WHERE tablename = 'objects' AND policyname LIKE '%profile%'
ORDER BY policyname;
```

### 3. Teste o Upload
1. Faça login como gerente
2. Vá para a aba "Usuários"
3. Tente adicionar um novo usuário com foto
4. **Abra o Console do Navegador (F12)** para monitorar os logs
5. Verifique se os logs detalhados aparecem sem erros

### 4. Logs de Debug Adicionados
Foi adicionado logging detalhado na função `uploadProfilePhoto()` para facilitar o diagnóstico:

```javascript
// Logs que você verá no console:
- uploadProfilePhoto: Starting upload process
- uploadProfilePhoto: File details: {name, size, type}
- uploadProfilePhoto: Auth check result
- uploadProfilePhoto: Farm data result
- uploadProfilePhoto: Upload details
- uploadProfilePhoto: Storage upload result
- uploadProfilePhoto: Public URL generated
```

## Configuração Aplicada

### Bucket Configuration:
- **Nome**: `profile-photos`
- **Público**: ✅ Sim (para visualização das fotos)
- **Limite de tamanho**: 5MB
- **Tipos permitidos**: JPEG, JPG, PNG, GIF, WEBP

### Políticas RLS:
1. **Visualização pública** (SELECT): Qualquer pessoa pode ver as fotos
2. **Operações autenticadas** (INSERT/UPDATE/DELETE): Usuários logados podem gerenciar fotos

## Estrutura de Arquivos
As fotos são organizadas por fazenda:
```
profile-photos/
├── farm_{farm_id}/
│   ├── {user_id}_{timestamp}.jpg
│   ├── {user_id}_{timestamp}.png
│   └── ...
└── ...
```

## Troubleshooting

### Se ainda houver erro 400:
1. **Verifique o console** para logs detalhados
2. **Confirme a autenticação** do usuário
3. **Verifique se o farm_id** está sendo encontrado
4. **Teste com arquivo menor** (< 1MB)

### Se o bucket não for encontrado:
1. Execute novamente o script SQL
2. Verifique se você tem permissões de administrador no Supabase
3. Confirme se está no projeto correto

### Se as políticas não funcionarem:
1. Remova todas as políticas manualmente no Dashboard
2. Execute apenas a parte de criação de políticas do script
3. Teste novamente

## Monitoramento
Após a correção, monitore:
- ✅ Upload de fotos funciona sem erros
- ✅ Fotos aparecem na lista de usuários
- ✅ Fotos aparecem no header do usuário
- ✅ URLs públicas são geradas corretamente

---
**Data da Correção:** $(Get-Date -Format "dd/MM/yyyy HH:mm")
**Arquivos Modificados:**
- `gerente.html` (logs de debug detalhados)
- `fix_profile_photo_upload_final.sql` (correção de políticas RLS)
- `CORREÇÃO_UPLOAD_FOTOS.md` (este guia)

**Próximos Passos:**
1. Execute o script SQL no Supabase
2. Teste o upload de fotos
3. Monitore os logs no console
4. Confirme que as fotos aparecem corretamente