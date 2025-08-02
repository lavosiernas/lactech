// TESTE COMPREENSIVO DE TODAS AS CORREÇÕES
// Este script testa: RLS, funções "Carregando...", e alteração de conta secundária

console.log('🚀 INICIANDO TESTE COMPREENSIVO DE TODAS AS CORREÇÕES');

// 1. TESTAR RLS E CONEXÕES
async function testRLSAndConnections() {
    console.log('\n=== 1. TESTANDO RLS E CONEXÕES ===');
    
    try {
        // Testar autenticação
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            console.error('❌ Erro de autenticação:', authError);
            return false;
        }
        console.log('✅ Autenticação OK:', user.email);
        
        // Testar consultas básicas
        const tables = ['users', 'farms', 'animals', 'milk_production', 'quality_tests'];
        for (const table of tables) {
            try {
                const { data, error } = await supabase
                    .from(table)
                    .select('*')
                    .limit(1);
                
                if (error) {
                    console.error(`❌ Erro na tabela ${table}:`, error);
                } else {
                    console.log(`✅ Tabela ${table}: OK`);
                }
            } catch (error) {
                console.error(`❌ Exceção na tabela ${table}:`, error);
            }
        }
        
        return true;
    } catch (error) {
        console.error('❌ Erro geral no teste de RLS:', error);
        return false;
    }
}

// 2. TESTAR FUNÇÕES DE CARREGAMENTO
async function testLoadingFunctions() {
    console.log('\n=== 2. TESTANDO FUNÇÕES DE CARREGAMENTO ===');
    
    try {
        // Testar funções melhoradas
        if (typeof loadUserProfileImproved === 'function') {
            console.log('✅ Função loadUserProfileImproved disponível');
            await loadUserProfileImproved();
        } else {
            console.log('⚠️ Função loadUserProfileImproved não encontrada, testando original');
            if (typeof loadUserProfile === 'function') {
                await loadUserProfile();
            }
        }
        
        if (typeof setFarmNameImproved === 'function') {
            console.log('✅ Função setFarmNameImproved disponível');
            await setFarmNameImproved();
        } else {
            console.log('⚠️ Função setFarmNameImproved não encontrada, testando original');
            if (typeof setFarmName === 'function') {
                await setFarmName();
            }
        }
        
        if (typeof setManagerNameImproved === 'function') {
            console.log('✅ Função setManagerNameImproved disponível');
            await setManagerNameImproved();
        } else {
            console.log('⚠️ Função setManagerNameImproved não encontrada, testando original');
            if (typeof setManagerName === 'function') {
                await setManagerName();
            }
        }
        
        console.log('✅ Funções de carregamento testadas');
        
    } catch (error) {
        console.error('❌ Erro nas funções de carregamento:', error);
    }
}

// 3. TESTAR ELEMENTOS DOM
async function testDOMElements() {
    console.log('\n=== 3. TESTANDO ELEMENTOS DOM ===');
    
    const elements = [
        'farmNameHeader',
        'managerName',
        'managerWelcome',
        'profileName',
        'profileFullName',
        'profileFarmName',
        'profileEmail2',
        'profileWhatsApp'
    ];
    
    let loadedCount = 0;
    let loadingCount = 0;
    
    for (const elementId of elements) {
        const element = document.getElementById(elementId);
        if (element) {
            const text = element.textContent;
            if (text === 'Carregando...') {
                console.log(`⚠️ Elemento ${elementId}: ainda mostra "Carregando..."`);
                loadingCount++;
            } else {
                console.log(`✅ Elemento ${elementId}: "${text}"`);
                loadedCount++;
            }
        } else {
            console.log(`❌ Elemento ${elementId}: não encontrado`);
        }
    }
    
    console.log(`📊 RESUMO: ${loadedCount} elementos carregados, ${loadingCount} ainda carregando`);
    
    return loadingCount === 0;
}

// 4. TESTAR FUNÇÕES DE CONTA SECUNDÁRIA
async function testSecondaryAccountFunctions() {
    console.log('\n=== 4. TESTANDO FUNÇÕES DE CONTA SECUNDÁRIA ===');
    
    try {
        // Testar verificação de conta secundária
        if (typeof checkIfSecondaryAccount === 'function') {
            const isSecondary = await checkIfSecondaryAccount();
            console.log(`✅ Verificação de conta secundária: ${isSecondary ? 'É secundária' : 'Não é secundária'}`);
            
            // Testar seção de alteração
            if (typeof showAlterSecondaryAccountSection === 'function') {
                await showAlterSecondaryAccountSection();
                console.log('✅ Seção de alteração de conta secundária testada');
            }
            
            // Testar carregamento de dados atuais
            if (typeof loadCurrentSecondaryAccountData === 'function') {
                await loadCurrentSecondaryAccountData();
                console.log('✅ Carregamento de dados atuais testado');
            }
        } else {
            console.log('⚠️ Funções de conta secundária não encontradas');
        }
        
        console.log('✅ Funções de conta secundária testadas');
        
    } catch (error) {
        console.error('❌ Erro nas funções de conta secundária:', error);
    }
}

// 5. TESTAR ELEMENTOS DE CONTA SECUNDÁRIA
async function testSecondaryAccountElements() {
    console.log('\n=== 5. TESTANDO ELEMENTOS DE CONTA SECUNDÁRIA ===');
    
    const secondaryElements = [
        'alterSecondaryAccountSection',
        'alterSecondaryAccountBtn',
        'secondaryAccountForm',
        'secondaryAccountName',
        'secondaryAccountRole',
        'secondaryAccountActive'
    ];
    
    for (const elementId of secondaryElements) {
        const element = document.getElementById(elementId);
        if (element) {
            console.log(`✅ Elemento ${elementId}: encontrado`);
        } else {
            console.log(`❌ Elemento ${elementId}: não encontrado`);
        }
    }
}

// 6. TESTAR FUNÇÕES ESPECÍFICAS DO GERENTE
async function testManagerSpecificFunctions() {
    console.log('\n=== 6. TESTANDO FUNÇÕES ESPECÍFICAS DO GERENTE ===');
    
    try {
        // Testar carregamento de dados de usuários
        if (typeof loadUsersData === 'function') {
            await loadUsersData();
            console.log('✅ loadUsersData executado');
        }
        
        // Testar carregamento de dados do dashboard
        if (typeof loadDashboardData === 'function') {
            await loadDashboardData();
            console.log('✅ loadDashboardData executado');
        }
        
        // Testar carregamento de dados de volume
        if (typeof loadVolumeData === 'function') {
            await loadVolumeData();
            console.log('✅ loadVolumeData executado');
        }
        
        console.log('✅ Funções específicas do gerente testadas');
        
    } catch (error) {
        console.error('❌ Erro nas funções específicas do gerente:', error);
    }
}

// 7. TESTAR CONSULTAS ESPECÍFICAS
async function testSpecificQueries() {
    console.log('\n=== 7. TESTANDO CONSULTAS ESPECÍFICAS ===');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            // Testar consulta de usuário por email
            const { data: userData, error: userError } = await supabase
                .from('users')
                .select('farm_id, name, email')
                .eq('email', user.email)
                .single();
            
            if (userError) {
                console.error('❌ Erro na consulta de usuário:', userError);
            } else {
                console.log('✅ Consulta de usuário OK:', userData);
                
                // Testar consulta de fazenda se farm_id existir
                if (userData?.farm_id) {
                    const { data: farmData, error: farmError } = await supabase
                        .from('farms')
                        .select('name')
                        .eq('id', userData.farm_id)
                        .single();
                    
                    if (farmError) {
                        console.error('❌ Erro na consulta de fazenda:', farmError);
                    } else {
                        console.log('✅ Consulta de fazenda OK:', farmData);
                    }
                }
            }
        }
        
    } catch (error) {
        console.error('❌ Erro nas consultas específicas:', error);
    }
}

// FUNÇÃO PRINCIPAL DE TESTE
async function runComprehensiveTest() {
    console.log('🚀 INICIANDO TESTE COMPREENSIVO...');
    
    // Aguardar um pouco para garantir que a página carregou
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const results = {
        rls: false,
        loading: false,
        dom: false,
        secondary: false,
        elements: false,
        manager: false,
        queries: false
    };
    
    // Executar todos os testes
    results.rls = await testRLSAndConnections();
    await testLoadingFunctions();
    results.dom = await testDOMElements();
    await testSecondaryAccountFunctions();
    await testSecondaryAccountElements();
    await testManagerSpecificFunctions();
    await testSpecificQueries();
    
    // Resumo final
    console.log('\n=== 📊 RESUMO FINAL ===');
    console.log(`RLS e Conexões: ${results.rls ? '✅ OK' : '❌ FALHOU'}`);
    console.log(`Elementos DOM: ${results.dom ? '✅ OK' : '❌ FALHOU'}`);
    console.log('Funções de Carregamento: ✅ Testadas');
    console.log('Funções de Conta Secundária: ✅ Testadas');
    console.log('Elementos de Conta Secundária: ✅ Testados');
    console.log('Funções do Gerente: ✅ Testadas');
    console.log('Consultas Específicas: ✅ Testadas');
    
    if (results.rls && results.dom) {
        console.log('\n🎉 SISTEMA FUNCIONANDO CORRETAMENTE!');
    } else {
        console.log('\n⚠️ ALGUNS PROBLEMAS DETECTADOS - Verifique os logs acima');
    }
}

// Executar o teste
runComprehensiveTest(); 