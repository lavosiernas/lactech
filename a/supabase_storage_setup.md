# Configuração do Supabase Storage para Fotos de Perfil

Este documento contém as instruções para configurar o bucket de armazenamento no Supabase para as fotos de perfil dos usuários.

## Passos para Configuração

### 1. Acessar o Painel do Supabase
1. Acesse [https://supabase.com](https://supabase.com)
2. Faça login na sua conta
3. Selecione o projeto do LacTech

### 2. Criar o Bucket de Storage
1. No painel lateral, clique em **Storage**
2. Clique em **Create a new bucket**
3. Configure o bucket com as seguintes informações:
   - **Name**: `profile-photos`
   - **Public bucket**: ✅ Marque esta opção (para permitir acesso público às imagens)
   - **File size limit**: 5MB (opcional, mas recomendado)
   - **Allowed MIME types**: `image/*` (opcional, mas recomendado)

### 3. Configurar Políticas de Segurança (RLS)

Após criar o bucket, você precisa configurar as políticas de Row Level Security (RLS) para controlar o acesso:

#### Política para Upload (INSERT)
```sql
CREATE POLICY "Users can upload their own profile photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Política para Visualização (SELECT)
```sql
CREATE POLICY "Profile photos are publicly viewable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-photos');
```

#### Política para Atualização (UPDATE)
```sql
CREATE POLICY "Users can update their own profile photos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

#### Política para Exclusão (DELETE)
```sql
CREATE POLICY "Users can delete their own profile photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-photos' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

### 4. Aplicar as Políticas
1. No painel do Supabase, vá para **SQL Editor**
2. Execute cada uma das políticas SQL acima
3. Verifique se todas foram aplicadas corretamente

### 5. Testar a Configuração
1. Faça login no sistema como gerente
2. Acesse o perfil do usuário
3. Tente fazer upload de uma foto de perfil
4. Verifique se a foto é exibida corretamente

## Estrutura de Arquivos

Os arquivos serão organizados da seguinte forma no bucket:
```
profile-photos/
├── {user_id}_timestamp.jpg
├── {user_id}_timestamp.png
└── ...
```

Onde:
- `{user_id}` é o ID único do usuário no Supabase Auth
- `timestamp` é o timestamp de quando o arquivo foi enviado
- A extensão do arquivo depende do tipo de imagem enviada

## Observações Importantes

1. **Tamanho máximo**: O sistema está configurado para aceitar imagens de até 5MB
2. **Tipos aceitos**: Apenas arquivos de imagem (image/*)
3. **Segurança**: As políticas garantem que cada usuário só pode gerenciar suas próprias fotos
4. **Acesso público**: As fotos são publicamente visíveis (necessário para exibição no sistema)
5. **Substituição**: Quando um usuário faz upload de uma nova foto, a anterior não é automaticamente excluída (pode ser implementado posteriormente)

## Troubleshooting

### Erro: "Bucket not found"
- Verifique se o bucket `profile-photos` foi criado corretamente
- Confirme se o nome está exatamente como `profile-photos`

### Erro: "Insufficient permissions"
- Verifique se as políticas RLS foram aplicadas corretamente
- Confirme se o bucket está marcado como público

### Erro: "File too large"
- O arquivo excede o limite de 5MB configurado no sistema
- Peça ao usuário para redimensionar a imagem

### Imagem não carrega
- Verifique se a URL pública está sendo gerada corretamente
- Confirme se o bucket está configurado como público