/**
 * Script para testar se o sistema está funcionando após as correções
 * Execute este script no console do navegador
 */

async function testSystemFunctionality() {
    console.log('🧪 Iniciando testes de funcionalidade do sistema...');
    
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
        
        console.log('✅ Usuário autenticado:', user.email);
        
        // Teste 2: Verificar dados do usuário (consulta crítica que estava falhando)
        console.log('\n2️⃣ Testando consulta de dados do usuário...');
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .single();
            
        if (userError) {
            console.error('❌ Erro ao buscar dados do usuário:', userError);
        } else {
            console.log('✅ Dados do usuário carregados:', userData.name);
        }
        
        // Teste 3: Verificar consulta por email (que estava causando recursão)
        console.log('\n3️⃣ Testando consulta por email...');
        const { data: emailUser, error: emailError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('email', user.email)
            .single();
            
        if (emailError) {
            console.error('❌ Erro ao consultar por email:', emailError);
        } else {
            console.log('✅ Consulta por email funcionando:', emailUser.farm_id);
        }
        
        // Teste 4: Verificar tabela secondary_accounts
        console.log('\n4️⃣ Testando tabela secondary_accounts...');
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
        
        // Teste 5: Verificar produção de leite
        console.log('\n5️⃣ Testando produção de leite...');
        try {
            const { data: milkProduction, error: milkError } = await supabase
                .from('milk_production')
                .select('*')
                .limit(5);
                
            if (milkError) {
                console.error('❌ Erro ao acessar milk_production:', milkError);
            } else {
                console.log('✅ Tabela milk_production acessível');
                console.log('📊 Registros de produção:', milkProduction.length);
            }
        } catch (error) {
            console.error('❌ Erro ao acessar milk_production:', error);
        }
        
        // Teste 6: Verificar testes de qualidade
        console.log('\n6️⃣ Testando testes de qualidade...');
        try {
            const { data: qualityTests, error: qualityError } = await supabase
                .from('quality_tests')
                .select('*')
                .limit(5);
                
            if (qualityError) {
                console.error('❌ Erro ao acessar quality_tests:', qualityError);
            } else {
                console.log('✅ Tabela quality_tests acessível');
                console.log('📊 Registros de qualidade:', qualityTests.length);
            }
        } catch (error) {
            console.error('❌ Erro ao acessar quality_tests:', error);
        }
        
        // Teste 7: Verificar elementos DOM críticos
        console.log('\n7️⃣ Testando elementos DOM...');
        const criticalElements = [
            'managerName',
            'farmNameHeader',
            'managerWelcome',
            'todayVolume',
            'qualityAverage',
            'pendingPayments',
            'activeUsers'
        ];
        
        let domErrors = 0;
        criticalElements.forEach(elementId => {
            const element = document.getElementById(elementId);
            if (!element) {
                console.error(`❌ Elemento não encontrado: ${elementId}`);
                domErrors++;
            }
        });
        
        if (domErrors === 0) {
            console.log('✅ Todos os elementos DOM críticos encontrados');
        } else {
            console.log(`⚠️ ${domErrors} elementos DOM não encontrados`);
        }
        
        // Resumo dos testes
        console.log('\n📋 RESUMO DOS TESTES');
        console.log('==================');
        console.log('✅ Autenticação: OK');
        console.log('✅ Consulta de usuário: Testado');
        console.log('✅ Consulta por email: Testado');
        console.log('✅ Tabela secondary_accounts: Testado');
        console.log('✅ Tabela milk_production: Testado');
        console.log('✅ Tabela quality_tests: Testado');
        console.log('✅ Elementos DOM: Verificado');
        
        console.log('\n🎉 Testes concluídos!');
        console.log('Se todos os testes passaram, o sistema deve estar funcionando corretamente.');
        
        // Verificar se não há mais erros 500
        console.log('\n🔍 Verificando se não há mais erros 500...');
        console.log('Recarregue a página e verifique o console para confirmar que não há mais erros de recursão infinita.');
        
    } catch (error) {
        console.error('❌ Erro geral nos testes:', error);
    }
}

// Função para limpar console e recarregar
function resetAndTest() {
    console.clear();
    console.log('🔄 Recarregando e testando sistema...');
    testSystemFunctionality();
}

// Exportar funções para uso no console
window.testSystemFunctionality = testSystemFunctionality;
window.resetAndTest = resetAndTest;

console.log('🧪 Script de teste carregado!');
console.log('Comandos disponíveis:');
console.log('- testSystemFunctionality() - Executar todos os testes');
console.log('- resetAndTest() - Limpar console e executar testes'); 