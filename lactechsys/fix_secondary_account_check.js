// FUNÇÃO MELHORADA PARA VERIFICAR CONTA SECUNDÁRIA
// Esta versão tem melhor tratamento de erro e fallbacks

// Função melhorada para verificar se o usuário atual é uma conta secundária
async function checkIfSecondaryAccountImproved() {
    try {
        console.log('🔍 Verificando se é conta secundária...');
        
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            console.log('⚠️ Usuário não autenticado, assumindo conta principal');
            return false;
        }
        
        console.log('👤 Usuário autenticado:', user.email);
        
        // Primeiro, verificar se a tabela secondary_accounts existe
        try {
            const { data: tableCheck, error: tableError } = await supabase
                .from('secondary_accounts')
                .select('id')
                .limit(1);
            
            if (tableError) {
                console.log('⚠️ Tabela secondary_accounts não existe ou não está acessível');
                console.log('📋 Erro:', tableError);
                return false;
            }
            
            console.log('✅ Tabela secondary_accounts acessível');
            
        } catch (error) {
            console.log('❌ Erro ao verificar tabela secondary_accounts:', error);
            return false;
        }
        
        // Agora verificar se existe uma relação na tabela secondary_accounts
        try {
            const { data: relation, error: relError } = await supabase
                .from('secondary_accounts')
                .select('primary_account_id')
                .eq('secondary_account_id', user.id)
                .single();
            
            if (relError) {
                if (relError.code === 'PGRST116') {
                    // Nenhum resultado encontrado - não é conta secundária
                    console.log('✅ Usuário não é conta secundária (nenhuma relação encontrada)');
                    return false;
                } else {
                    console.log('❌ Erro ao verificar relação:', relError);
                    return false;
                }
            }
            
            if (relation && relation.primary_account_id) {
                console.log('✅ Usuário é conta secundária');
                console.log('📋 ID da conta principal:', relation.primary_account_id);
                return true;
            }
            
            console.log('⚠️ Relação encontrada mas sem primary_account_id');
            return false;
            
        } catch (error) {
            console.log('❌ Erro ao verificar relação de conta secundária:', error);
            return false;
        }
        
    } catch (error) {
        console.error('❌ Erro geral ao verificar conta secundária:', error);
        return false;
    }
}

// Função para testar a verificação
async function testSecondaryAccountCheck() {
    console.log('🧪 TESTANDO VERIFICAÇÃO DE CONTA SECUNDÁRIA');
    
    try {
        const isSecondary = await checkIfSecondaryAccountImproved();
        
        console.log(`📊 RESULTADO: ${isSecondary ? 'É CONTA SECUNDÁRIA' : 'É CONTA PRINCIPAL'}`);
        
        if (isSecondary) {
            console.log('🔵 Comportamento esperado:');
            console.log('   - Seções principais devem estar OCULTAS');
            console.log('   - Seção de retorno deve estar VISÍVEL');
        } else {
            console.log('🟢 Comportamento esperado:');
            console.log('   - Seções principais devem estar VISÍVEIS');
            console.log('   - Seção de retorno deve estar OCULTA');
        }
        
        return isSecondary;
        
    } catch (error) {
        console.error('❌ Erro no teste:', error);
        return false;
    }
}

// Função para substituir a função original
function replaceSecondaryAccountCheck() {
    if (typeof window !== 'undefined') {
        // Substituir a função original pela melhorada
        window.checkIfSecondaryAccount = checkIfSecondaryAccountImproved;
        
        console.log('✅ Função checkIfSecondaryAccount substituída pela versão melhorada');
        
        // Também substituir a função de teste se existir
        if (typeof testSecondaryAccountCheck === 'function') {
            window.testSecondaryAccountCheck = testSecondaryAccountCheck;
            console.log('✅ Função de teste disponível como testSecondaryAccountCheck');
        }
    }
}

// Executar a substituição
replaceSecondaryAccountCheck();

// Função para diagnóstico completo
async function diagnoseSecondaryAccountIssue() {
    console.log('🔧 DIAGNÓSTICO COMPLETO DE CONTA SECUNDÁRIA');
    
    try {
        // 1. Verificar autenticação
        console.log('\n1. Verificando autenticação...');
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        
        if (authError) {
            console.error('❌ Erro de autenticação:', authError);
            return;
        }
        
        if (!user) {
            console.log('⚠️ Usuário não autenticado');
            return;
        }
        
        console.log('✅ Usuário autenticado:', user.email);
        console.log('📋 User ID:', user.id);
        
        // 2. Verificar se a tabela existe
        console.log('\n2. Verificando tabela secondary_accounts...');
        try {
            const { data: tableCheck, error: tableError } = await supabase
                .from('secondary_accounts')
                .select('id')
                .limit(1);
            
            if (tableError) {
                console.error('❌ Erro na tabela secondary_accounts:', tableError);
                console.log('💡 Execute o script fix_secondary_accounts_table.sql no Supabase');
                return;
            }
            
            console.log('✅ Tabela secondary_accounts acessível');
            
        } catch (error) {
            console.error('❌ Erro ao verificar tabela:', error);
            return;
        }
        
        // 3. Verificar relações existentes
        console.log('\n3. Verificando relações existentes...');
        try {
            const { data: relations, error: relError } = await supabase
                .from('secondary_accounts')
                .select('*');
            
            if (relError) {
                console.error('❌ Erro ao buscar relações:', relError);
                return;
            }
            
            console.log(`📊 Total de relações encontradas: ${relations?.length || 0}`);
            
            if (relations && relations.length > 0) {
                console.log('📋 Relações existentes:');
                relations.forEach((rel, index) => {
                    console.log(`   ${index + 1}. Primary: ${rel.primary_account_id} → Secondary: ${rel.secondary_account_id}`);
                });
            } else {
                console.log('📋 Nenhuma relação encontrada na tabela');
            }
            
        } catch (error) {
            console.error('❌ Erro ao verificar relações:', error);
        }
        
        // 4. Verificar se o usuário atual é secundário
        console.log('\n4. Verificando se usuário atual é secundário...');
        try {
            const { data: userRelation, error: userRelError } = await supabase
                .from('secondary_accounts')
                .select('primary_account_id')
                .eq('secondary_account_id', user.id)
                .single();
            
            if (userRelError) {
                if (userRelError.code === 'PGRST116') {
                    console.log('✅ Usuário NÃO é conta secundária (nenhuma relação encontrada)');
                } else {
                    console.error('❌ Erro ao verificar relação do usuário:', userRelError);
                }
            } else {
                console.log('✅ Usuário É conta secundária');
                console.log('📋 Conta principal ID:', userRelation.primary_account_id);
            }
            
        } catch (error) {
            console.error('❌ Erro ao verificar relação do usuário:', error);
        }
        
        console.log('\n🔧 DIAGNÓSTICO CONCLUÍDO');
        
    } catch (error) {
        console.error('❌ Erro no diagnóstico:', error);
    }
}

// Função para executar diagnóstico
if (typeof window !== 'undefined') {
    window.diagnoseSecondaryAccountIssue = diagnoseSecondaryAccountIssue;
    console.log('✅ Função de diagnóstico disponível como diagnoseSecondaryAccountIssue');
} 