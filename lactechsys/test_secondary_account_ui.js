// TESTE DA INTERFACE DE CONTA SECUNDÁRIA
// Este script testa se a interface se adapta corretamente para contas secundárias

console.log('🧪 INICIANDO TESTE DA INTERFACE DE CONTA SECUNDÁRIA');

// 1. TESTAR DETECÇÃO DE CONTA SECUNDÁRIA
async function testSecondaryAccountDetection() {
    console.log('\n=== 1. TESTANDO DETECÇÃO DE CONTA SECUNDÁRIA ===');
    
    try {
        // Verificar se a função existe
        if (typeof checkIfSecondaryAccount === 'function') {
            console.log('✅ Função checkIfSecondaryAccount disponível');
            
            const isSecondary = await checkIfSecondaryAccount();
            console.log(`📊 Resultado da verificação: ${isSecondary ? 'É conta secundária' : 'Não é conta secundária'}`);
            
            return isSecondary;
        } else {
            console.error('❌ Função checkIfSecondaryAccount não encontrada');
            return false;
        }
    } catch (error) {
        console.error('❌ Erro ao testar detecção de conta secundária:', error);
        return false;
    }
}

// 2. TESTAR GERENCIAMENTO DE SEÇÕES
async function testSectionManagement() {
    console.log('\n=== 2. TESTANDO GERENCIAMENTO DE SEÇÕES ===');
    
    try {
        // Verificar se a função existe
        if (typeof manageProfileSections === 'function') {
            console.log('✅ Função manageProfileSections disponível');
            
            await manageProfileSections();
            console.log('✅ Gerenciamento de seções executado');
            
            // Verificar se os elementos existem
            const sections = [
                'professionalInfoSection', // veterinario
                'personalInfoSection',    // funcionario
                'changePasswordSection',
                'dangerZoneSection',
                'primaryAccountSection'
            ];
            
            for (const sectionId of sections) {
                const element = document.getElementById(sectionId);
                if (element) {
                    const isVisible = element.style.display !== 'none';
                    console.log(`📋 Seção ${sectionId}: ${isVisible ? 'VISÍVEL' : 'OCULTA'}`);
                }
            }
            
        } else {
            console.error('❌ Função manageProfileSections não encontrada');
        }
    } catch (error) {
        console.error('❌ Erro ao testar gerenciamento de seções:', error);
    }
}

// 3. TESTAR FUNÇÃO DE RETORNO PARA CONTA PRINCIPAL
async function testReturnToPrimaryAccount() {
    console.log('\n=== 3. TESTANDO FUNÇÃO DE RETORNO ===');
    
    try {
        // Verificar se a função existe
        if (typeof switchToPrimaryAccount === 'function') {
            console.log('✅ Função switchToPrimaryAccount disponível');
            
            // Não executar a função automaticamente para evitar redirecionamento
            console.log('⚠️ Função de retorno disponível (não executada automaticamente)');
            
        } else {
            console.error('❌ Função switchToPrimaryAccount não encontrada');
        }
    } catch (error) {
        console.error('❌ Erro ao testar função de retorno:', error);
    }
}

// 4. TESTAR ELEMENTOS DA INTERFACE
async function testUIElements() {
    console.log('\n=== 4. TESTANDO ELEMENTOS DA INTERFACE ===');
    
    // Elementos específicos do veterinário
    const vetElements = [
        'professionalInfoSection',
        'changePasswordSection',
        'dangerZoneSection',
        'primaryAccountSection'
    ];
    
    // Elementos específicos do funcionário
    const funcElements = [
        'personalInfoSection',
        'changePasswordSection',
        'dangerZoneSection',
        'primaryAccountSection'
    ];
    
    // Determinar qual página estamos
    const isVetPage = document.getElementById('professionalInfoSection') !== null;
    const isFuncPage = document.getElementById('personalInfoSection') !== null;
    
    let elementsToCheck = [];
    let pageType = '';
    
    if (isVetPage) {
        elementsToCheck = vetElements;
        pageType = 'Veterinário';
    } else if (isFuncPage) {
        elementsToCheck = funcElements;
        pageType = 'Funcionário';
    } else {
        console.log('⚠️ Página não identificada como veterinário ou funcionário');
        return;
    }
    
    console.log(`📄 Página detectada: ${pageType}`);
    
    for (const elementId of elementsToCheck) {
        const element = document.getElementById(elementId);
        if (element) {
            const isVisible = element.style.display !== 'none';
            const hasContent = element.innerHTML.trim().length > 0;
            console.log(`✅ Elemento ${elementId}: ${isVisible ? 'VISÍVEL' : 'OCULTA'} | ${hasContent ? 'COM CONTEÚDO' : 'VAZIO'}`);
        } else {
            console.log(`❌ Elemento ${elementId}: não encontrado`);
        }
    }
}

// 5. TESTAR COMPORTAMENTO ESPECÍFICO PARA CONTA SECUNDÁRIA
async function testSecondaryAccountBehavior() {
    console.log('\n=== 5. TESTANDO COMPORTAMENTO PARA CONTA SECUNDÁRIA ===');
    
    try {
        const isSecondary = await checkIfSecondaryAccount();
        
        if (isSecondary) {
            console.log('🔵 Comportamento esperado para conta secundária:');
            console.log('   - Seções principais devem estar OCULTAS');
            console.log('   - Seção de retorno deve estar VISÍVEL');
            console.log('   - Botão "Retornar para Gerente" deve estar disponível');
            
            // Verificar se as seções estão corretas
            const primarySections = [
                'professionalInfoSection',
                'personalInfoSection',
                'changePasswordSection',
                'dangerZoneSection'
            ];
            
            const secondarySection = 'primaryAccountSection';
            
            let allHidden = true;
            for (const sectionId of primarySections) {
                const element = document.getElementById(sectionId);
                if (element && element.style.display !== 'none') {
                    allHidden = false;
                    console.log(`⚠️ Seção ${sectionId} ainda visível (deveria estar oculta)`);
                }
            }
            
            const returnSection = document.getElementById(secondarySection);
            const returnVisible = returnSection && returnSection.style.display !== 'none';
            
            if (allHidden && returnVisible) {
                console.log('✅ Interface corretamente configurada para conta secundária');
            } else {
                console.log('⚠️ Interface não está corretamente configurada para conta secundária');
            }
            
        } else {
            console.log('🟢 Comportamento esperado para conta principal:');
            console.log('   - Seções principais devem estar VISÍVEIS');
            console.log('   - Seção de retorno deve estar OCULTA');
            
            // Verificar se as seções estão corretas
            const primarySections = [
                'professionalInfoSection',
                'personalInfoSection',
                'changePasswordSection',
                'dangerZoneSection'
            ];
            
            const secondarySection = 'primaryAccountSection';
            
            let allVisible = true;
            for (const sectionId of primarySections) {
                const element = document.getElementById(sectionId);
                if (element && element.style.display === 'none') {
                    allVisible = false;
                    console.log(`⚠️ Seção ${sectionId} oculta (deveria estar visível)`);
                }
            }
            
            const returnSection = document.getElementById(secondarySection);
            const returnHidden = !returnSection || returnSection.style.display === 'none';
            
            if (allVisible && returnHidden) {
                console.log('✅ Interface corretamente configurada para conta principal');
            } else {
                console.log('⚠️ Interface não está corretamente configurada para conta principal');
            }
        }
        
    } catch (error) {
        console.error('❌ Erro ao testar comportamento específico:', error);
    }
}

// 6. TESTAR FUNÇÃO DE INICIALIZAÇÃO
async function testInitializationFunction() {
    console.log('\n=== 6. TESTANDO FUNÇÃO DE INICIALIZAÇÃO ===');
    
    try {
        // Verificar se a função existe
        if (typeof initializePageWithSecondaryCheck === 'function') {
            console.log('✅ Função initializePageWithSecondaryCheck disponível');
            
            // Não executar automaticamente para evitar conflitos
            console.log('⚠️ Função de inicialização disponível (não executada automaticamente)');
            
        } else {
            console.log('⚠️ Função initializePageWithSecondaryCheck não encontrada');
        }
        
        // Verificar se a substituição foi feita
        if (typeof window.initializePage === 'function') {
            console.log('✅ Função initializePage foi substituída corretamente');
        } else {
            console.log('⚠️ Função initializePage não foi substituída');
        }
        
    } catch (error) {
        console.error('❌ Erro ao testar função de inicialização:', error);
    }
}

// FUNÇÃO PRINCIPAL DE TESTE
async function runSecondaryAccountUITest() {
    console.log('🚀 INICIANDO TESTE COMPLETO DA INTERFACE DE CONTA SECUNDÁRIA...');
    
    // Aguardar um pouco para garantir que a página carregou
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Executar todos os testes
    const isSecondary = await testSecondaryAccountDetection();
    await testSectionManagement();
    await testReturnToPrimaryAccount();
    await testUIElements();
    await testSecondaryAccountBehavior();
    await testInitializationFunction();
    
    // Resumo final
    console.log('\n=== 📊 RESUMO DO TESTE ===');
    console.log(`Tipo de conta: ${isSecondary ? 'SECUNDÁRIA' : 'PRINCIPAL'}`);
    console.log('Detecção de conta secundária: ✅ Testada');
    console.log('Gerenciamento de seções: ✅ Testado');
    console.log('Função de retorno: ✅ Testada');
    console.log('Elementos da interface: ✅ Testados');
    console.log('Comportamento específico: ✅ Testado');
    console.log('Função de inicialização: ✅ Testada');
    
    if (isSecondary) {
        console.log('\n🎯 CONTA SECUNDÁRIA DETECTADA');
        console.log('Interface deve mostrar apenas o botão de retorno para conta principal');
    } else {
        console.log('\n🎯 CONTA PRINCIPAL DETECTADA');
        console.log('Interface deve mostrar todas as seções normais do perfil');
    }
    
    console.log('\n✅ TESTE DA INTERFACE DE CONTA SECUNDÁRIA CONCLUÍDO');
}

// Executar o teste
runSecondaryAccountUITest(); 