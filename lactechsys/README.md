# Sistema LacTech - Gestão de Fazendas Leiteiras

## Visão Geral

O LacTech é um sistema multi-fazendas de controle leiteiro desenvolvido para otimizar a gestão de propriedades produtoras de leite. A plataforma oferece uma solução completa para monitoramento da produção, qualidade do leite, saúde animal, gestão financeira e administração de equipes, tudo integrado em uma interface moderna e responsiva.

O sistema foi projetado com uma arquitetura multi-usuário que permite diferentes níveis de acesso e funcionalidades específicas para cada perfil, garantindo que todos os envolvidos na cadeia produtiva tenham as ferramentas necessárias para suas funções.

## Arquitetura do Sistema

O LacTech é construído como uma aplicação web utilizando:
- **Frontend**: HTML5, CSS (framework Tailwind) e JavaScript puro
- **Backend**: Supabase (PostgreSQL + APIs RESTful)
- **Autenticação**: Sistema de autenticação do Supabase
- **Visualização de Dados**: Chart.js para gráficos e dashboards interativos

A aplicação segue um modelo de Single Page Application (SPA) com múltiplas páginas HTML que correspondem aos diferentes perfis de usuário, cada uma com funcionalidades específicas.

## Perfis de Usuário e Hierarquia de Acesso

O sistema possui quatro perfis de usuário principais, cada um com acesso a funcionalidades específicas. A hierarquia de acesso é estabelecida durante o processo de primeiro acesso, onde o usuário inicial (que pode ser um proprietário ou um gerente) configura a fazenda e cria sua conta administrativa.

### Fluxo de Criação de Contas

O sistema permite dois cenários principais para o primeiro acesso:

1. **Proprietário como Primeiro Usuário**: Quando o proprietário da fazenda realiza o primeiro acesso através da página `PrimeiroAcesso.html`, ele configura a fazenda (informando nome, CNPJ/CPF, localização, dados do rebanho) e cria sua própria conta com o perfil de "proprietário". Posteriormente, ele pode criar contas para gerentes, funcionários e veterinários através do painel administrativo.

2. **Gerente como Primeiro Usuário**: Alternativamente, um gerente pode realizar o primeiro acesso, configurar a fazenda e criar sua conta com o perfil de "gerente". Neste caso, ele poderá posteriormente criar contas para funcionários e veterinários através do painel de gerente. No entanto, conforme observado no código da página `gerente.html`, o gerente tem permissão limitada para criar apenas usuários com perfis de "funcionário" e "veterinário", não podendo criar outros gerentes ou proprietários.

Esta flexibilidade permite que a configuração inicial seja realizada por qualquer pessoa designada, seja o proprietário ou um gerente contratado para administrar a fazenda. Após o primeiro acesso, a hierarquia de criação de contas segue as seguintes regras:

- **Proprietário**: Pode criar contas de qualquer tipo (gerentes, funcionários e veterinários)
- **Gerente**: Pode criar apenas contas de funcionários e veterinários
- **Funcionários e Veterinários**: Não podem criar novas contas

### Proprietário
- Visão completa da fazenda
- Acesso a relatórios financeiros detalhados
- Monitoramento de produção e qualidade
- Gestão estratégica do negócio
- Visualização de todos os usuários e suas atividades

### Gerente
- Administração diária da fazenda
- Gestão de pagamentos e finanças
- Monitoramento de volume e qualidade do leite
- Gerenciamento de usuários e permissões
- Acesso a relatórios operacionais

### Funcionário
- Registro diário de produção leiteira
- Visualização de histórico de registros
- Acesso a relatórios básicos de produção
- Monitoramento de métricas de desempenho

### Veterinário
- Monitoramento da saúde do rebanho
- Registro de tratamentos e medicações
- Acompanhamento de indicadores de saúde animal
- Alertas para animais em estado crítico
- Histórico médico completo dos animais

## Funcionalidades Principais

### Controle de Produção
- Registro de volume de leite por ordenha (manhã/tarde/noite)
- Histórico completo de produção
- Gráficos de produção diária, semanal e mensal
- Identificação de tendências e sazonalidades
- Comparativos de desempenho

### Monitoramento de Qualidade
- Registro de parâmetros como gordura, proteína, CCS e CBT
- Classificação automática da qualidade do leite
- Alertas para desvios de qualidade
- Histórico de testes e resultados

### Gestão de Saúde Animal
- Cadastro completo do rebanho
- Histórico médico de cada animal
- Registro de tratamentos e medicações
- Alertas para animais em estado crítico
- Calendário de vacinação e procedimentos

### Gestão Financeira
- Registro de pagamentos recebidos
- Controle de bonificações por qualidade
- Relatórios financeiros detalhados
- Projeções de receita
- Análise de rentabilidade

### Gestão de Equipe
- Cadastro de funcionários, gerentes e veterinários
- Controle de acesso por perfil
- Monitoramento de atividades
- Sistema de notificações

## Estrutura do Banco de Dados

O banco de dados do LacTech é hospedado no Supabase e possui a seguinte estrutura:

### Tabelas Principais

#### farms
Armazena informações sobre as fazendas cadastradas no sistema:
- Dados cadastrais (nome, CNPJ/CPF, localização)
- Informações do proprietário
- Dados de contato
- Métricas gerais (área total, quantidade de animais, produção média)

#### users
Registra todos os usuários do sistema:
- Dados pessoais (nome, email, telefone)
- Credenciais de acesso (criptografadas)
- Tipo de perfil (proprietário, gerente, funcionário, veterinário)
- Vínculo com a fazenda (farm_id)
- Status de ativação

#### animals
Cadastro completo do rebanho:
- Identificação única
- Características (raça, idade, peso)
- Status de saúde atual
- Histórico de produção
- Indicadores de produtividade

#### milk_production
Registros diários de produção de leite:
- Volume por ordenha
- Data e hora do registro
- Funcionário responsável
- Observações relevantes

#### quality_tests
Resultados de análises de qualidade do leite:
- Percentual de gordura
- Percentual de proteína
- Contagem de Células Somáticas (CCS)
- Contagem Bacteriana Total (CBT)
- Data da análise

#### animal_health_records
Histórico de saúde de cada animal:
- Diagnósticos
- Sintomas observados
- Data do registro
- Veterinário responsável

#### treatments
Registro de tratamentos aplicados:
- Animal tratado
- Medicação utilizada
- Dosagem e via de administração
- Período de carência
- Veterinário responsável

#### payments
Controle financeiro da produção:
- Valores recebidos
- Data do pagamento
- Volume correspondente
- Bonificações por qualidade
- Descontos aplicados

#### notifications
Sistema de alertas e comunicações:
- Tipo de notificação
- Destinatário
- Status de leitura
- Data de envio

#### user_access_requests
Solicitações de acesso ao sistema:
- Dados do solicitante
- Fazenda de interesse
- Status da solicitação
- Data do pedido

### Segurança e Controle de Acesso

O sistema utiliza Row Level Security (RLS) do PostgreSQL para garantir que cada usuário tenha acesso apenas aos dados pertinentes à sua fazenda e ao seu perfil. As políticas de segurança são implementadas em nível de banco de dados, garantindo que mesmo em caso de falhas na aplicação, os dados permaneçam protegidos.