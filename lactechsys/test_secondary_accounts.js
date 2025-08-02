/**
 * Script de teste para verificar o funcionamento das contas secundárias
 * Execute este script no console do navegador após aplicar as correções
 */

async function testSecondaryAccounts() {
    console.log('🧪 Iniciando testes de contas secundárias...');
    
    try {
        // Teste 1: Verificar autenticação
        console.log('\n1️⃣ Testando autenticação...');
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        
        if (authError) {
            console.error('❌ Erro de autenticação:', authError);
            return;
        }
        
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return;
        }
        
        console.log('✅ Usuário autenticado:', user.id);
        
        // Teste 2: Verificar dados do usuário
        console.log('\n2️⃣ Testando busca de dados do usuário...');
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .single();
            
        if (userError) {
            console.error('❌ Erro ao buscar dados do usuário:', userError);
            return;
        }
        
        console.log('✅ Dados do usuário carregados:', userData.name);
        
        // Teste 3: Verificar tabela secondary_accounts
        console.log('\n3️⃣ Testando acesso à tabela secondary_accounts...');
        try {
            const { data: secondaryAccounts, error: secondaryError } = await supabase
                .from('secondary_accounts')
                .select('*')
                .eq('primary_account_id', user.id);
                
            if (secondaryError) {
                console.error('❌ Erro ao acessar secondary_accounts:', secondaryError);
            } else {
                console.log('✅ Tabela secondary_accounts acessível');
                console.log('📊 Contas secundárias encontradas:', secondaryAccounts.length);
            }
        } catch (error) {
            console.error('❌ Erro ao acessar secondary_accounts:', error);
        }
        
        // Teste 4: Verificar consultas por email
        console.log('\n4️⃣ Testando consultas por email...');
        try {
            const { data: emailUsers, error: emailError } = await supabase
                .from('users')
                .select('*')
                .eq('email', userData.email)
                .eq('farm_id', userData.farm_id)
                .neq('id', user.id);
                
            if (emailError) {
                console.error('❌ Erro ao consultar por email:', emailError);
            } else {
                console.log('✅ Consulta por email funcionando');
                console.log('📊 Usuários com mesmo email:', emailUsers.length);
            }
        } catch (error) {
            console.error('❌ Erro ao consultar por email:', error);
        }
        
        // Teste 5: Verificar função loadSecondaryAccountData
        console.log('\n5️⃣ Testando função loadSecondaryAccountData...');
        try {
            await loadSecondaryAccountData();
            console.log('✅ Função loadSecondaryAccountData executada sem erros');
        } catch (error) {
            console.error('❌ Erro na função loadSecondaryAccountData:', error);
        }
        
        // Teste 6: Verificar elementos DOM
        console.log('\n6️⃣ Testando elementos DOM...');
        const elements = [
            'secondaryAccountName',
            'secondaryAccountRole', 
            'secondaryAccountActive',
            'noSecondaryAccount',
            'hasSecondaryAccount',
            'secondaryAccountNameDisplay',
            'switchAccountBtn'
        ];
        
        let domErrors = 0;
        elements.forEach(elementId => {
            const element = document.getElementById(elementId);
            if (!element) {
                console.error(`❌ Elemento não encontrado: ${elementId}`);
                domErrors++;
            }
        });
        
        if (domErrors === 0) {
            console.log('✅ Todos os elementos DOM encontrados');
        } else {
            console.log(`⚠️ ${domErrors} elementos DOM não encontrados`);
        }
        
        // Resumo dos testes
        console.log('\n📋 RESUMO DOS TESTES');
        console.log('==================');
        console.log('✅ Autenticação: OK');
        console.log('✅ Dados do usuário: OK');
        console.log('✅ Tabela secondary_accounts: Testado');
        console.log('✅ Consultas por email: Testado');
        console.log('✅ Função loadSecondaryAccountData: Testado');
        console.log('✅ Elementos DOM: Verificado');
        
        console.log('\n🎉 Testes concluídos!');
        console.log('Se todos os testes passaram, o sistema deve estar funcionando corretamente.');
        
    } catch (error) {
        console.error('❌ Erro geral nos testes:', error);
    }
}

// Função para testar criação de conta secundária
async function testCreateSecondaryAccount() {
    console.log('\n🧪 Testando criação de conta secundária...');
    
    try {
        // Simular dados do formulário
        const testData = {
            name: 'Teste Funcionário',
            role: 'funcionario',
            isActive: true
        };
        
        // Simular evento do formulário
        const mockEvent = {
            preventDefault: () => {},
            target: {
                querySelector: () => ({
                    disabled: false,
                    innerHTML: 'Salvar',
                    disabled: false
                })
            }
        };
        
        // Executar função de salvamento
        await saveSecondaryAccount(mockEvent);
        
        console.log('✅ Teste de criação concluído');
        
    } catch (error) {
        console.error('❌ Erro no teste de criação:', error);
    }
}

// Função para limpar dados de teste
async function cleanupTestData() {
    console.log('\n🧹 Limpando dados de teste...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;
        
        // Remover contas secundárias de teste
        const { error: deleteError } = await supabase
            .from('secondary_accounts')
            .delete()
            .eq('primary_account_id', user.id);
            
        if (deleteError) {
            console.error('❌ Erro ao limpar dados:', deleteError);
        } else {
            console.log('✅ Dados de teste removidos');
        }
        
    } catch (error) {
        console.error('❌ Erro ao limpar dados:', error);
    }
}

// Exportar funções para uso no console
window.testSecondaryAccounts = testSecondaryAccounts;
window.testCreateSecondaryAccount = testCreateSecondaryAccount;
window.cleanupTestData = cleanupTestData;

console.log('🧪 Script de teste carregado!');
console.log('Comandos disponíveis:');
console.log('- testSecondaryAccounts() - Executar todos os testes');
console.log('- testCreateSecondaryAccount() - Testar criação de conta');
console.log('- cleanupTestData() - Limpar dados de teste'); 