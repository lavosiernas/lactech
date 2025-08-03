# 🔗 CONFIGURAÇÃO MCP COM POSTGRESQL - LACTECH

## 📋 Configuração Atualizada

O arquivo `mcp_config.json` foi criado com a configuração completa para conectar ao PostgreSQL do Supabase.

## 🔧 Configuração do MCP

### **1. Substitua os valores no arquivo:**

```json
{
  "mcpServers": {
    "supabase": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--read-only",
        "--project-ref=lzqbzztoawjnqwgffhjv"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "SEU_TOKEN_AQUI"
      }
    },
    "postgres": {
      "command": "cmd",
      "args": [
        "/c",
        "npx",
        "-y",
        "@modelcontextprotocol/server-postgres@latest"
      ],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://postgres.lzqbzztoawjnqwgffhjv:SUA_SENHA_AQUI@aws-0-sa-east-1.pooler.supabase.com:5432/postgres"
      }
    }
  }
}
```

## 🔑 Valores que você precisa substituir:

### **1. SUPABASE_ACCESS_TOKEN**:
- Vá para https://supabase.com/dashboard/account/tokens
- Crie um novo token de acesso pessoal
- Substitua `SEU_TOKEN_AQUI` pelo token gerado

### **2. POSTGRES_CONNECTION_STRING**:
- Substitua `SUA_SENHA_AQUI` pela senha do seu banco PostgreSQL
- A senha pode ser encontrada em:
  - Supabase Dashboard → Settings → Database
  - Ou na configuração inicial do projeto

## 📁 Como aplicar a configuração:

### **Opção 1: Copiar para o arquivo MCP do Cursor**
1. Abra o arquivo: `C:\Users\[SEU_USUARIO]\.cursor\mcp.json`
2. Substitua todo o conteúdo pelo conteúdo do `mcp_config.json`
3. Substitua os valores conforme indicado acima

### **Opção 2: Usar o arquivo do projeto**
1. Copie o conteúdo do `mcp_config.json`
2. Cole no arquivo MCP do Cursor
3. Substitua os valores conforme indicado acima

## 🚀 Servidores MCP Configurados:

### **1. Supabase Server**:
- ✅ Conecta ao projeto Supabase
- ✅ Acesso somente leitura
- ✅ Project ID: `lzqbzztoawjnqwgffhjv`

### **2. PostgreSQL Server**:
- ✅ Conecta diretamente ao banco PostgreSQL
- ✅ Host: `aws-0-sa-east-1.pooler.supabase.com`
- ✅ Porta: `5432`
- ✅ Database: `postgres`

## 🔍 Como verificar se está funcionando:

### **1. Reinicie o Cursor**:
- Feche e abra o Cursor
- Os servidores MCP serão carregados automaticamente

### **2. Verifique os logs**:
- Abra o console do Cursor
- Procure por mensagens de conexão MCP

### **3. Teste a conexão**:
- Tente fazer uma consulta ao banco
- Verifique se não há erros de conexão

## 📊 Benefícios da Configuração:

### **✅ Supabase MCP**:
- ✅ Acesso direto aos dados do Supabase
- ✅ Consultas SQL otimizadas
- ✅ Integração com autenticação

### **✅ PostgreSQL MCP**:
- ✅ Acesso direto ao banco PostgreSQL
- ✅ Consultas SQL nativas
- ✅ Performance otimizada

## 🛠️ Comandos úteis:

### **Para instalar dependências**:
```bash
npm install -g @supabase/mcp-server-supabase
npm install -g @modelcontextprotocol/server-postgres
```

### **Para testar conexão**:
```bash
# Teste Supabase
npx @supabase/mcp-server-supabase --project-ref=lzqbzztoawjnqwgffhjv

# Teste PostgreSQL
npx @modelcontextprotocol/server-postgres
```

## 🔒 Segurança:

### **⚠️ Importante**:
- ✅ Nunca compartilhe seus tokens
- ✅ Use variáveis de ambiente quando possível
- ✅ Mantenha as senhas seguras
- ✅ Revogue tokens não utilizados

## 📞 Suporte:

Se encontrar problemas:

1. **Verifique** se os tokens estão corretos
2. **Teste** a conexão manualmente
3. **Consulte** os logs do Cursor
4. **Reinicie** o Cursor se necessário

---

**✅ Com esta configuração, você terá acesso direto ao banco de dados PostgreSQL do Supabase através do MCP!** 