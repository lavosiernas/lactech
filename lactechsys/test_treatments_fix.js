/**
 * Script para testar a correção da tabela treatments
 * Execute este script no console do navegador
 */

// Teste 1: Verificar se a consulta que estava falhando funciona
async function testTreatmentsQuery() {
    console.log('🧪 Testando consulta de tratamentos...');
    
    try {
        // Testar a consulta que estava causando erro 400
        const { data: activeTreatments, error } = await supabase
            .from('treatments')
            .select('id')
            .eq('status', 'active');
            
        if (error) {
            console.error('❌ Erro na consulta de tratamentos ativos:', error);
            return false;
        }
        
        console.log('✅ Consulta de tratamentos ativos funcionando');
        console.log('📊 Tratamentos ativos encontrados:', activeTreatments?.length || 0);
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar consulta:', error);
        return false;
    }
}

// Teste 2: Verificar estrutura da tabela
async function testTreatmentsStructure() {
    console.log('🧪 Testando estrutura da tabela treatments...');
    
    try {
        // Testar consulta com todas as colunas
        const { data: treatments, error } = await supabase
            .from('treatments')
            .select('*')
            .limit(1);
            
        if (error) {
            console.error('❌ Erro ao consultar estrutura:', error);
            return false;
        }
        
        if (treatments && treatments.length > 0) {
            const treatment = treatments[0];
            console.log('✅ Estrutura da tabela treatments:');
            console.log('📋 Colunas disponíveis:', Object.keys(treatment));
            
            // Verificar colunas importantes
            const requiredColumns = ['id', 'status', 'treatment_type', 'medication_name', 'veterinarian_id'];
            const missingColumns = requiredColumns.filter(col => !(col in treatment));
            
            if (missingColumns.length > 0) {
                console.error('❌ Colunas faltando:', missingColumns);
                return false;
            } else {
                console.log('✅ Todas as colunas necessárias estão presentes');
                return true;
            }
        } else {
            console.log('ℹ️ Tabela treatments está vazia (isso é normal)');
            return true;
        }
        
    } catch (error) {
        console.error('❌ Erro ao testar estrutura:', error);
        return false;
    }
}

// Teste 3: Testar inserção de tratamento
async function testTreatmentInsertion() {
    console.log('🧪 Testando inserção de tratamento...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return false;
        }
        
        // Buscar um animal para o teste
        const { data: animals, error: animalsError } = await supabase
            .from('animals')
            .select('id')
            .limit(1);
            
        if (animalsError || !animals || animals.length === 0) {
            console.log('ℹ️ Nenhum animal encontrado para teste');
            return true; // Não é um erro, apenas não há dados
        }
        
        const testTreatment = {
            animal_id: animals[0].id,
            treatment_type: 'medication',
            medication_name: 'Teste de Medicação',
            dosage: '10ml',
            start_date: new Date().toISOString().split('T')[0],
            status: 'active',
            veterinarian_id: user.id,
            notes: 'Tratamento de teste'
        };
        
        const { data: insertedTreatment, error } = await supabase
            .from('treatments')
            .insert([testTreatment])
            .select();
            
        if (error) {
            console.error('❌ Erro ao inserir tratamento:', error);
            return false;
        }
        
        console.log('✅ Tratamento inserido com sucesso:', insertedTreatment[0]);
        
        // Limpar o tratamento de teste
        const { error: deleteError } = await supabase
            .from('treatments')
            .delete()
            .eq('id', insertedTreatment[0].id);
            
        if (deleteError) {
            console.warn('⚠️ Erro ao limpar tratamento de teste:', deleteError);
        } else {
            console.log('✅ Tratamento de teste removido');
        }
        
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar inserção:', error);
        return false;
    }
}

// Teste 4: Testar consultas específicas
async function testSpecificQueries() {
    console.log('🧪 Testando consultas específicas...');
    
    const queries = [
        {
            name: 'Tratamentos por status',
            query: () => supabase.from('treatments').select('id, status').eq('status', 'active')
        },
        {
            name: 'Tratamentos por tipo',
            query: () => supabase.from('treatments').select('id, treatment_type').eq('treatment_type', 'medication')
        },
        {
            name: 'Tratamentos por veterinário',
            query: () => supabase.from('treatments').select('id, veterinarian_id').limit(5)
        }
    ];
    
    let allPassed = true;
    
    for (const test of queries) {
        try {
            const { data, error } = await test.query();
            
            if (error) {
                console.error(`❌ ${test.name}:`, error);
                allPassed = false;
            } else {
                console.log(`✅ ${test.name}: ${data?.length || 0} registros encontrados`);
            }
        } catch (error) {
            console.error(`❌ ${test.name}:`, error);
            allPassed = false;
        }
    }
    
    return allPassed;
}

// Teste completo
async function runTreatmentsTest() {
    console.log('🚀 Iniciando teste completo da tabela treatments...\n');
    
    const results = {
        query: await testTreatmentsQuery(),
        structure: await testTreatmentsStructure(),
        insertion: await testTreatmentInsertion(),
        specific: await testSpecificQueries()
    };
    
    console.log('\n📊 RESULTADOS DOS TESTES:');
    console.log(`✅ Consulta básica: ${results.query ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Estrutura da tabela: ${results.structure ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Inserção de dados: ${results.insertion ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Consultas específicas: ${results.specific ? 'PASSOU' : 'FALHOU'}`);
    
    const allPassed = Object.values(results).every(result => result);
    
    if (allPassed) {
        console.log('\n🎉 TODOS OS TESTES PASSARAM!');
        console.log('✅ Tabela treatments está funcionando corretamente');
    } else {
        console.log('\n⚠️ ALGUNS TESTES FALHARAM');
        console.log('❌ Ainda há problemas com a tabela treatments');
    }
    
    return allPassed;
}

// Exportar funções
window.testTreatmentsQuery = testTreatmentsQuery;
window.testTreatmentsStructure = testTreatmentsStructure;
window.testTreatmentInsertion = testTreatmentInsertion;
window.testSpecificQueries = testSpecificQueries;
window.runTreatmentsTest = runTreatmentsTest;

console.log('🧪 Script de teste da tabela treatments carregado!');
console.log('Comandos disponíveis:');
console.log('- testTreatmentsQuery() - Testar consulta básica');
console.log('- testTreatmentsStructure() - Testar estrutura da tabela');
console.log('- testTreatmentInsertion() - Testar inserção de dados');
console.log('- testSpecificQueries() - Testar consultas específicas');
console.log('- runTreatmentsTest() - Executar teste completo'); 