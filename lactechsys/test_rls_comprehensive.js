// TESTE COMPREENSIVO DO RLS E FUNÇÕES DE CARREGAMENTO
// Este script testa se o RLS está funcionando e se as funções "Carregando..." estão carregando dados

console.log('=== INICIANDO TESTE COMPREENSIVO DO RLS ===');

// 1. TESTAR CONEXÃO COM SUPABASE
async function testSupabaseConnection() {
    try {
        console.log('1. Testando conexão com Supabase...');
        const { data: { user }, error } = await supabase.auth.getUser();
        
        if (error) {
            console.error('❌ Erro na autenticação:', error);
            return false;
        }
        
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return false;
        }
        
        console.log('✅ Usuário autenticado:', user.email);
        return true;
    } catch (error) {
        console.error('❌ Erro na conexão:', error);
        return false;
    }
}

// 2. TESTAR CONSULTAS BÁSICAS NAS TABELAS
async function testBasicQueries() {
    const tables = [
        'users',
        'farms', 
        'animals',
        'milk_production',
        'quality_tests',
        'animal_health_records',
        'treatments',
        'payments',
        'notifications',
        'user_access_requests',
        'secondary_accounts'
    ];
    
    console.log('2. Testando consultas básicas...');
    
    for (const table of tables) {
        try {
            const { data, error } = await supabase
                .from(table)
                .select('*')
                .limit(1);
            
            if (error) {
                console.error(`❌ Erro na tabela ${table}:`, error);
            } else {
                console.log(`✅ Tabela ${table}: OK (${data?.length || 0} registros)`);
            }
        } catch (error) {
            console.error(`❌ Exceção na tabela ${table}:`, error);
        }
    }
}

// 3. TESTAR FUNÇÕES DE CARREGAMENTO DE DADOS
async function testDataLoadingFunctions() {
    console.log('3. Testando funções de carregamento...');
    
    try {
        // Testar getFarmName
        console.log('Testando getFarmName...');
        const farmName = await getFarmName();
        console.log('✅ Farm name:', farmName);
        
        // Testar getManagerName
        console.log('Testando getManagerName...');
        const managerName = await getManagerName();
        console.log('✅ Manager name:', managerName);
        
        // Testar loadUserProfile
        console.log('Testando loadUserProfile...');
        await loadUserProfile();
        console.log('✅ User profile carregado');
        
    } catch (error) {
        console.error('❌ Erro nas funções de carregamento:', error);
    }
}

// 4. TESTAR ELEMENTOS DOM QUE MOSTRAM "Carregando..."
async function testLoadingElements() {
    console.log('4. Testando elementos DOM...');
    
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
    
    for (const elementId of elements) {
        const element = document.getElementById(elementId);
        if (element) {
            const text = element.textContent;
            if (text === 'Carregando...') {
                console.log(`⚠️ Elemento ${elementId}: ainda mostra "Carregando..."`);
            } else {
                console.log(`✅ Elemento ${elementId}: "${text}"`);
            }
        } else {
            console.log(`❌ Elemento ${elementId}: não encontrado`);
        }
    }
}

// 5. TESTAR FUNÇÕES ESPECÍFICAS DO GERENTE
async function testManagerFunctions() {
    console.log('5. Testando funções específicas do gerente...');
    
    try {
        // Testar setFarmName
        await setFarmName();
        console.log('✅ setFarmName executado');
        
        // Testar setManagerName
        await setManagerName();
        console.log('✅ setManagerName executado');
        
        // Testar loadSecondaryAccountData
        await loadSecondaryAccountData();
        console.log('✅ loadSecondaryAccountData executado');
        
    } catch (error) {
        console.error('❌ Erro nas funções do gerente:', error);
    }
}

// 6. TESTAR CONSULTAS ESPECÍFICAS QUE PODEM FALHAR
async function testSpecificQueries() {
    console.log('6. Testando consultas específicas...');
    
    try {
        // Testar consulta de usuário por email
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            const { data, error } = await supabase
                .from('users')
                .select('farm_id')
                .eq('email', user.email)
                .single();
            
            if (error) {
                console.error('❌ Erro na consulta de usuário:', error);
            } else {
                console.log('✅ Consulta de usuário OK:', data);
            }
        }
        
        // Testar consulta de fazenda
        if (user) {
            const { data: userData } = await supabase
                .from('users')
                .select('farm_id')
                .eq('email', user.email)
                .single();
            
            if (userData?.farm_id) {
                const { data: farmData, error } = await supabase
                    .from('farms')
                    .select('name')
                    .eq('id', userData.farm_id)
                    .single();
                
                if (error) {
                    console.error('❌ Erro na consulta de fazenda:', error);
                } else {
                    console.log('✅ Consulta de fazenda OK:', farmData);
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
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Executar todos os testes
    await testSupabaseConnection();
    await testBasicQueries();
    await testDataLoadingFunctions();
    await testLoadingElements();
    await testManagerFunctions();
    await testSpecificQueries();
    
    console.log('✅ TESTE COMPREENSIVO CONCLUÍDO');
    console.log('📊 RESUMO: Verifique os logs acima para identificar problemas');
}

// Executar o teste
runComprehensiveTest(); 