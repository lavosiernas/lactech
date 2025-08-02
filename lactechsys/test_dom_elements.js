/**
 * Script para verificar elementos DOM necessários para contas secundárias
 * Execute este script no console do navegador
 */

function checkSecondaryAccountElements() {
    console.log('🔍 Verificando elementos DOM para contas secundárias...');
    
    const elements = {
        // Elementos do formulário
        'secondaryAccountForm': 'Formulário de conta secundária',
        'secondaryAccountName': 'Campo nome da conta secundária',
        'secondaryAccountRole': 'Campo função da conta secundária',
        'secondaryAccountActive': 'Checkbox ativo da conta secundária',
        
        // Elementos de status
        'noSecondaryAccount': 'Div "sem conta secundária"',
        'hasSecondaryAccount': 'Div "com conta secundária"',
        'secondaryAccountNameDisplay': 'Display do nome da conta secundária',
        'switchAccountBtn': 'Botão de alternar conta',
        
        // Elementos de configuração
        'configSecondaryBtn': 'Botão configurar conta secundária',
        
        // Elementos de cards
        'accountCards': 'Container de cards de contas'
    };
    
    const results = {};
    let allElementsExist = true;
    
    for (const [id, description] of Object.entries(elements)) {
        const element = document.getElementById(id);
        const exists = element !== null;
        results[id] = {
            exists,
            description,
            element: element
        };
        
        if (!exists) {
            allElementsExist = false;
        }
        
        console.log(`${exists ? '✅' : '❌'} ${id}: ${description}`);
    }
    
    console.log('\n📊 RESUMO:');
    console.log(`Elementos encontrados: ${Object.values(results).filter(r => r.exists).length}/${Object.keys(results).length}`);
    
    if (allElementsExist) {
        console.log('🎉 Todos os elementos necessários estão presentes!');
    } else {
        console.log('⚠️ Alguns elementos estão faltando:');
        Object.entries(results).forEach(([id, result]) => {
            if (!result.exists) {
                console.log(`   - ${id}: ${result.description}`);
            }
        });
    }
    
    return results;
}

// Função para testar a criação de conta secundária
function testSecondaryAccountCreation() {
    console.log('🧪 Testando criação de conta secundária...');
    
    // Verificar se estamos na página correta
    if (!document.getElementById('secondaryAccountForm')) {
        console.error('❌ Não estamos na página de gerente ou elementos não carregaram');
        return;
    }
    
    // Simular preenchimento do formulário
    const nameField = document.getElementById('secondaryAccountName');
    const roleField = document.getElementById('secondaryAccountRole');
    const activeField = document.getElementById('secondaryAccountActive');
    
    if (nameField && roleField && activeField) {
        console.log('✅ Campos do formulário encontrados');
        
        // Simular preenchimento
        nameField.value = 'Teste Funcionário';
        roleField.value = 'funcionario';
        activeField.checked = true;
        
        console.log('📝 Formulário preenchido com dados de teste');
        console.log('💡 Para testar a criação real, clique em "Salvar Configurações"');
    } else {
        console.error('❌ Campos do formulário não encontrados');
    }
}

// Função para verificar se o usuário está autenticado
async function checkAuthentication() {
    console.log('🔐 Verificando autenticação...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        
        if (user) {
            console.log('✅ Usuário autenticado:', user.email);
            
            // Verificar dados do usuário
            const { data: userData, error } = await supabase
                .from('users')
                .select('name, role, farm_id')
                .eq('id', user.id)
                .single();
                
            if (error) {
                console.error('❌ Erro ao buscar dados do usuário:', error);
            } else {
                console.log('📊 Dados do usuário:', userData);
            }
        } else {
            console.error('❌ Usuário não autenticado');
        }
    } catch (error) {
        console.error('❌ Erro ao verificar autenticação:', error);
    }
}

// Função para testar todas as funcionalidades
async function runFullTest() {
    console.log('🚀 Iniciando teste completo...\n');
    
    // 1. Verificar autenticação
    await checkAuthentication();
    console.log('');
    
    // 2. Verificar elementos DOM
    checkSecondaryAccountElements();
    console.log('');
    
    // 3. Testar criação de conta secundária
    testSecondaryAccountCreation();
    
    console.log('\n🎉 Teste completo finalizado!');
}

// Exportar funções
window.checkSecondaryAccountElements = checkSecondaryAccountElements;
window.testSecondaryAccountCreation = testSecondaryAccountCreation;
window.checkAuthentication = checkAuthentication;
window.runFullTest = runFullTest;

console.log('🧪 Script de verificação de elementos DOM carregado!');
console.log('Comandos disponíveis:');
console.log('- checkSecondaryAccountElements() - Verificar elementos DOM');
console.log('- testSecondaryAccountCreation() - Testar criação de conta');
console.log('- checkAuthentication() - Verificar autenticação');
console.log('- runFullTest() - Executar teste completo'); 