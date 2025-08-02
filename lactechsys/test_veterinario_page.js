/**
 * Script para testar a página do veterinário após remoção do CRMV
 * Execute este script no console do navegador
 */

// Teste 1: Verificar se a página carrega sem erros
function testPageLoad() {
    console.log('🧪 Testando carregamento da página do veterinário...');
    
    // Verificar se estamos na página correta
    if (!window.location.pathname.includes('veterinario.html')) {
        console.log('ℹ️ Não estamos na página do veterinário');
        return false;
    }
    
    console.log('✅ Estamos na página do veterinário');
    
    // Verificar elementos essenciais
    const essentialElements = [
        'vetName',
        'vetWelcome', 
        'profileName',
        'profileFullName',
        'profileEmail2',
        'profilePhone',
        'profileSpecialty'
    ];
    
    let allElementsExist = true;
    
    essentialElements.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            console.log(`✅ ${id}: Elemento encontrado`);
        } else {
            console.error(`❌ ${id}: Elemento não encontrado`);
            allElementsExist = false;
        }
    });
    
    // Verificar se o CRMV foi removido
    const crmvElement = document.getElementById('profileCrmv');
    if (crmvElement) {
        console.error('❌ Campo CRMV ainda existe');
        allElementsExist = false;
    } else {
        console.log('✅ Campo CRMV removido com sucesso');
    }
    
    return allElementsExist;
}

// Teste 2: Verificar se os dados são carregados corretamente
async function testDataLoading() {
    console.log('🧪 Testando carregamento de dados...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return false;
        }
        
        console.log('✅ Usuário autenticado:', user.email);
        
        // Verificar dados do usuário
        const { data: userData, error } = await supabase
            .from('users')
            .select('name, email, whatsapp, role')
            .eq('id', user.id)
            .single();
            
        if (error) {
            console.error('❌ Erro ao buscar dados do usuário:', error);
            return false;
        }
        
        console.log('✅ Dados do usuário carregados:', userData);
        
        // Verificar se os campos estão sendo preenchidos
        const profileFullName = document.getElementById('profileFullName');
        const profileEmail2 = document.getElementById('profileEmail2');
        const profilePhone = document.getElementById('profilePhone');
        
        if (profileFullName && profileFullName.textContent !== 'Carregando...') {
            console.log('✅ Nome carregado:', profileFullName.textContent);
        } else {
            console.log('ℹ️ Nome ainda carregando...');
        }
        
        if (profileEmail2 && profileEmail2.textContent !== 'Carregando...') {
            console.log('✅ Email carregado:', profileEmail2.textContent);
        } else {
            console.log('ℹ️ Email ainda carregando...');
        }
        
        if (profilePhone && profilePhone.textContent !== 'Carregando...') {
            console.log('✅ Telefone carregado:', profilePhone.textContent);
        } else {
            console.log('ℹ️ Telefone ainda carregando...');
        }
        
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar carregamento de dados:', error);
        return false;
    }
}

// Teste 3: Verificar layout da seção de informações profissionais
function testProfessionalInfoLayout() {
    console.log('🧪 Testando layout das informações profissionais...');
    
    // Verificar se a seção existe
    const professionalSection = document.querySelector('h4');
    if (professionalSection && professionalSection.textContent.includes('Informações Profissionais')) {
        console.log('✅ Seção de informações profissionais encontrada');
    } else {
        console.error('❌ Seção de informações profissionais não encontrada');
        return false;
    }
    
    // Verificar campos presentes
    const expectedFields = [
        'Nome Completo',
        'Email', 
        'Telefone',
        'Especialidade',
        'Cargo'
    ];
    
    const pageText = document.body.textContent;
    let allFieldsPresent = true;
    
    expectedFields.forEach(field => {
        if (pageText.includes(field)) {
            console.log(`✅ Campo "${field}" presente`);
        } else {
            console.error(`❌ Campo "${field}" não encontrado`);
            allFieldsPresent = false;
        }
    });
    
    // Verificar se CRMV não está presente
    if (pageText.includes('CRMV')) {
        console.error('❌ Campo CRMV ainda presente na página');
        allFieldsPresent = false;
    } else {
        console.log('✅ Campo CRMV completamente removido');
    }
    
    return allFieldsPresent;
}

// Teste 4: Verificar funcionalidades básicas
function testBasicFunctionality() {
    console.log('🧪 Testando funcionalidades básicas...');
    
    // Verificar se o modal de perfil abre
    const profileButton = document.querySelector('button[onclick="openProfileModal()"]');
    if (profileButton) {
        console.log('✅ Botão de perfil encontrado');
    } else {
        console.error('❌ Botão de perfil não encontrado');
        return false;
    }
    
    // Verificar se as abas funcionam
    const navItems = document.querySelectorAll('.nav-item');
    if (navItems.length > 0) {
        console.log(`✅ ${navItems.length} abas de navegação encontradas`);
    } else {
        console.error('❌ Abas de navegação não encontradas');
        return false;
    }
    
    // Verificar se o dashboard carrega
    const dashboardElements = [
        'healthyAnimals',
        'warningAnimals', 
        'criticalAnimals',
        'activeTreatments'
    ];
    
    let dashboardElementsExist = true;
    
    dashboardElements.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            console.log(`✅ Elemento do dashboard "${id}" encontrado`);
        } else {
            console.error(`❌ Elemento do dashboard "${id}" não encontrado`);
            dashboardElementsExist = false;
        }
    });
    
    return dashboardElementsExist;
}

// Teste completo
async function runVeterinarioTest() {
    console.log('🚀 Iniciando teste completo da página do veterinário...\n');
    
    const results = {
        pageLoad: testPageLoad(),
        dataLoading: await testDataLoading(),
        layout: testProfessionalInfoLayout(),
        functionality: testBasicFunctionality()
    };
    
    console.log('\n📊 RESULTADOS DOS TESTES:');
    console.log(`✅ Carregamento da página: ${results.pageLoad ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Carregamento de dados: ${results.dataLoading ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Layout das informações: ${results.layout ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Funcionalidades básicas: ${results.functionality ? 'PASSOU' : 'FALHOU'}`);
    
    const allPassed = Object.values(results).every(result => result);
    
    if (allPassed) {
        console.log('\n🎉 TODOS OS TESTES PASSARAM!');
        console.log('✅ Página do veterinário funcionando corretamente');
        console.log('✅ Campo CRMV removido com sucesso');
    } else {
        console.log('\n⚠️ ALGUNS TESTES FALHARAM');
        console.log('❌ Ainda há problemas na página do veterinário');
    }
    
    return allPassed;
}

// Exportar funções
window.testPageLoad = testPageLoad;
window.testDataLoading = testDataLoading;
window.testProfessionalInfoLayout = testProfessionalInfoLayout;
window.testBasicFunctionality = testBasicFunctionality;
window.runVeterinarioTest = runVeterinarioTest;

console.log('🧪 Script de teste da página do veterinário carregado!');
console.log('Comandos disponíveis:');
console.log('- testPageLoad() - Testar carregamento da página');
console.log('- testDataLoading() - Testar carregamento de dados');
console.log('- testProfessionalInfoLayout() - Testar layout das informações');
console.log('- testBasicFunctionality() - Testar funcionalidades básicas');
console.log('- runVeterinarioTest() - Executar teste completo'); 