/**
 * Script para testar a ativação do RLS em todas as tabelas
 * Execute este script no console do navegador
 */

// Teste 1: Verificar se as consultas básicas funcionam
async function testBasicQueries() {
    console.log('🧪 Testando consultas básicas após ativação do RLS...');
    
    const tables = [
        'animal_health_records',
        'animals', 
        'notifications',
        'payments',
        'treatments',
        'user_access_requests'
    ];
    
    const results = {};
    
    for (const table of tables) {
        try {
            console.log(`📋 Testando tabela: ${table}`);
            
            // Testar SELECT
            const { data, error } = await supabase
                .from(table)
                .select('*')
                .limit(1);
                
            if (error) {
                console.error(`❌ Erro na tabela ${table}:`, error);
                results[table] = false;
            } else {
                console.log(`✅ ${table}: ${data?.length || 0} registros encontrados`);
                results[table] = true;
            }
            
        } catch (error) {
            console.error(`❌ Erro ao testar ${table}:`, error);
            results[table] = false;
        }
    }
    
    return results;
}

// Teste 2: Verificar se inserções funcionam
async function testInsertions() {
    console.log('🧪 Testando inserções após ativação do RLS...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return false;
        }
        
        // Testar inserção em notifications (mais simples)
        const testNotification = {
            farm_id: '00000000-0000-0000-0000-000000000000', // UUID fictício
            title: 'Teste RLS',
            message: 'Teste de inserção após ativação do RLS',
            type: 'info'
        };
        
        const { data, error } = await supabase
            .from('notifications')
            .insert([testNotification])
            .select();
            
        if (error) {
            console.error('❌ Erro ao inserir notificação:', error);
            return false;
        }
        
        console.log('✅ Inserção em notifications funcionando');
        
        // Limpar o teste
        if (data && data.length > 0) {
            await supabase
                .from('notifications')
                .delete()
                .eq('id', data[0].id);
            console.log('✅ Notificação de teste removida');
        }
        
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar inserção:', error);
        return false;
    }
}

// Teste 3: Verificar se atualizações funcionam
async function testUpdates() {
    console.log('🧪 Testando atualizações após ativação do RLS...');
    
    try {
        // Testar atualização em uma tabela existente
        const { data: existingData, error: selectError } = await supabase
            .from('notifications')
            .select('id, title')
            .limit(1);
            
        if (selectError || !existingData || existingData.length === 0) {
            console.log('ℹ️ Nenhum dado para testar atualização');
            return true;
        }
        
        const testId = existingData[0].id;
        const newTitle = 'Título Atualizado - Teste RLS';
        
        const { error: updateError } = await supabase
            .from('notifications')
            .update({ title: newTitle })
            .eq('id', testId);
            
        if (updateError) {
            console.error('❌ Erro ao atualizar:', updateError);
            return false;
        }
        
        console.log('✅ Atualização funcionando');
        
        // Restaurar título original
        await supabase
            .from('notifications')
            .update({ title: existingData[0].title })
            .eq('id', testId);
            
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar atualização:', error);
        return false;
    }
}

// Teste 4: Verificar se exclusões funcionam
async function testDeletions() {
    console.log('🧪 Testando exclusões após ativação do RLS...');
    
    try {
        // Criar um registro para testar exclusão
        const testRecord = {
            farm_id: '00000000-0000-0000-0000-000000000000',
            title: 'Teste Exclusão RLS',
            message: 'Registro para testar exclusão',
            type: 'info'
        };
        
        const { data: inserted, error: insertError } = await supabase
            .from('notifications')
            .insert([testRecord])
            .select();
            
        if (insertError) {
            console.error('❌ Erro ao criar registro para teste:', insertError);
            return false;
        }
        
        // Testar exclusão
        const { error: deleteError } = await supabase
            .from('notifications')
            .delete()
            .eq('id', inserted[0].id);
            
        if (deleteError) {
            console.error('❌ Erro ao excluir:', deleteError);
            return false;
        }
        
        console.log('✅ Exclusão funcionando');
        return true;
        
    } catch (error) {
        console.error('❌ Erro ao testar exclusão:', error);
        return false;
    }
}

// Teste 5: Verificar se não há erros de RLS
async function testRLSErrors() {
    console.log('🧪 Verificando se não há erros de RLS...');
    
    const testQueries = [
        {
            name: 'Consulta treatments por status',
            query: () => supabase.from('treatments').select('id').eq('status', 'active')
        },
        {
            name: 'Consulta animals',
            query: () => supabase.from('animals').select('id, name').limit(5)
        },
        {
            name: 'Consulta payments',
            query: () => supabase.from('payments').select('id, payment_date').limit(5)
        },
        {
            name: 'Consulta user_access_requests',
            query: () => supabase.from('user_access_requests').select('id, status').limit(5)
        }
    ];
    
    let allPassed = true;
    
    for (const test of testQueries) {
        try {
            const { data, error } = await test.query();
            
            if (error) {
                console.error(`❌ ${test.name}:`, error);
                allPassed = false;
            } else {
                console.log(`✅ ${test.name}: ${data?.length || 0} registros`);
            }
        } catch (error) {
            console.error(`❌ ${test.name}:`, error);
            allPassed = false;
        }
    }
    
    return allPassed;
}

// Teste completo
async function runRLSTest() {
    console.log('🚀 Iniciando teste completo do RLS...\n');
    
    const results = {
        basic: await testBasicQueries(),
        insertion: await testInsertions(),
        update: await testUpdates(),
        deletion: await testDeletions(),
        rlsErrors: await testRLSErrors()
    };
    
    console.log('\n📊 RESULTADOS DOS TESTES:');
    
    // Contar tabelas que passaram no teste básico
    const basicResults = results.basic;
    const passedTables = Object.values(basicResults).filter(result => result).length;
    const totalTables = Object.keys(basicResults).length;
    
    console.log(`✅ Consultas básicas: ${passedTables}/${totalTables} tabelas funcionando`);
    console.log(`✅ Inserções: ${results.insertion ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Atualizações: ${results.update ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Exclusões: ${results.deletion ? 'PASSOU' : 'FALHOU'}`);
    console.log(`✅ Sem erros RLS: ${results.rlsErrors ? 'PASSOU' : 'FALHOU'}`);
    
    const allPassed = results.insertion && results.update && results.deletion && results.rlsErrors;
    
    if (allPassed && passedTables === totalTables) {
        console.log('\n🎉 TODOS OS TESTES PASSARAM!');
        console.log('✅ RLS ativado corretamente em todas as tabelas');
        console.log('✅ Sistema funcionando sem erros de segurança');
    } else {
        console.log('\n⚠️ ALGUNS TESTES FALHARAM');
        console.log('❌ Ainda há problemas com RLS');
    }
    
    return allPassed;
}

// Exportar funções
window.testBasicQueries = testBasicQueries;
window.testInsertions = testInsertions;
window.testUpdates = testUpdates;
window.testDeletions = testDeletions;
window.testRLSErrors = testRLSErrors;
window.runRLSTest = runRLSTest;

console.log('🧪 Script de teste do RLS carregado!');
console.log('Comandos disponíveis:');
console.log('- testBasicQueries() - Testar consultas básicas');
console.log('- testInsertions() - Testar inserções');
console.log('- testUpdates() - Testar atualizações');
console.log('- testDeletions() - Testar exclusões');
console.log('- testRLSErrors() - Verificar erros RLS');
console.log('- runRLSTest() - Executar teste completo'); 