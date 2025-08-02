// INCLUIR MELHORIAS DE CONTA SECUNDÁRIA
// Este script inclui as funções melhoradas nas páginas

console.log('🔧 INCLUINDO MELHORIAS DE CONTA SECUNDÁRIA');

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

// Função melhorada para gerenciar a visibilidade das seções do perfil
async function manageProfileSectionsImproved() {
    try {
        console.log('🎛️ Gerenciando seções do perfil...');
        
        const isSecondary = await checkIfSecondaryAccountImproved();
        
        // Elementos para contas principais (veterinário)
        const professionalInfoSection = document.getElementById('professionalInfoSection');
        const personalInfoSection = document.getElementById('personalInfoSection');
        const changePasswordSection = document.getElementById('changePasswordSection');
        const dangerZoneSection = document.getElementById('dangerZoneSection');
        
        // Elementos para contas secundárias
        const primaryAccountSection = document.getElementById('primaryAccountSection');
        
        if (isSecondary) {
            // Se é conta secundária, ocultar seções principais e mostrar seção de retorno
            if (professionalInfoSection) {
                professionalInfoSection.style.display = 'none';
                console.log('📋 Seção professionalInfoSection ocultada');
            }
            if (personalInfoSection) {
                personalInfoSection.style.display = 'none';
                console.log('📋 Seção personalInfoSection ocultada');
            }
            if (changePasswordSection) {
                changePasswordSection.style.display = 'none';
                console.log('📋 Seção changePasswordSection ocultada');
            }
            if (dangerZoneSection) {
                dangerZoneSection.style.display = 'none';
                console.log('📋 Seção dangerZoneSection ocultada');
            }
            if (primaryAccountSection) {
                primaryAccountSection.style.display = 'block';
                console.log('📋 Seção primaryAccountSection mostrada');
            }
            
            console.log('✅ Perfil configurado para conta secundária');
        } else {
            // Se é conta principal, mostrar seções principais e ocultar seção de retorno
            if (professionalInfoSection) {
                professionalInfoSection.style.display = 'block';
                console.log('📋 Seção professionalInfoSection mostrada');
            }
            if (personalInfoSection) {
                personalInfoSection.style.display = 'block';
                console.log('📋 Seção personalInfoSection mostrada');
            }
            if (changePasswordSection) {
                changePasswordSection.style.display = 'block';
                console.log('📋 Seção changePasswordSection mostrada');
            }
            if (dangerZoneSection) {
                dangerZoneSection.style.display = 'block';
                console.log('📋 Seção dangerZoneSection mostrada');
            }
            if (primaryAccountSection) {
                primaryAccountSection.style.display = 'none';
                console.log('📋 Seção primaryAccountSection ocultada');
            }
            
            console.log('✅ Perfil configurado para conta principal');
        }
        
    } catch (error) {
        console.error('❌ Erro ao gerenciar seções do perfil:', error);
    }
}

// Função melhorada para retornar para a conta principal
async function switchToPrimaryAccountImproved() {
    try {
        console.log('🔄 Iniciando retorno para conta principal...');
        
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            alert('Usuário não autenticado');
            return;
        }
        
        console.log('👤 Usuário atual:', user.email);
        
        // Buscar a relação de conta secundária
        const { data: relation, error: relError } = await supabase
            .from('secondary_accounts')
            .select('primary_account_id')
            .eq('secondary_account_id', user.id)
            .single();
        
        if (relError) {
            console.error('❌ Erro ao encontrar conta principal:', relError);
            alert('Erro ao encontrar conta principal');
            return;
        }
        
        if (!relation || !relation.primary_account_id) {
            console.error('❌ Relação de conta secundária não encontrada');
            alert('Relação de conta secundária não encontrada');
            return;
        }
        
        console.log('📋 ID da conta principal:', relation.primary_account_id);
        
        // Buscar dados da conta principal
        const { data: primaryAccount, error: primaryError } = await supabase
            .from('users')
            .select('*')
            .eq('id', relation.primary_account_id)
            .single();
        
        if (primaryError || !primaryAccount) {
            console.error('❌ Erro ao carregar dados da conta principal:', primaryError);
            alert('Erro ao carregar dados da conta principal');
            return;
        }
        
        console.log('✅ Dados da conta principal carregados:', primaryAccount.email);
        
        // Armazenar dados da conta secundária atual
        const currentSession = {
            id: user.id,
            email: user.email,
            name: user.name,
            user_type: user.user_metadata?.role || 'veterinario',
            farm_id: user.user_metadata?.farm_id || '',
            farm_name: sessionStorage.getItem('farm_name') || ''
        };
        
        // Armazenar dados da conta principal
        const primarySession = {
            id: primaryAccount.id,
            email: primaryAccount.email,
            name: primaryAccount.name,
            user_type: primaryAccount.role,
            farm_id: primaryAccount.farm_id,
            farm_name: sessionStorage.getItem('farm_name') || ''
        };
        
        // Salvar sessão atual para retorno posterior
        sessionStorage.setItem('secondary_account', JSON.stringify(currentSession));
        console.log('💾 Sessão secundária salva');
        
        // Definir nova sessão como conta principal
        sessionStorage.setItem('user', JSON.stringify(primarySession));
        console.log('💾 Sessão principal definida');
        
        console.log('🔄 Redirecionando para gerente.html...');
        
        // Redirecionar para a página do gerente
        window.location.href = 'gerente.html';
        
    } catch (error) {
        console.error('❌ Erro ao retornar para conta principal:', error);
        alert('Ocorreu um erro ao retornar para a conta principal.');
    }
}

// Função para substituir as funções originais
function replaceSecondaryAccountFunctions() {
    if (typeof window !== 'undefined') {
        // Substituir funções originais pelas melhoradas
        window.checkIfSecondaryAccount = checkIfSecondaryAccountImproved;
        window.manageProfileSections = manageProfileSectionsImproved;
        window.switchToPrimaryAccount = switchToPrimaryAccountImproved;
        
        console.log('✅ Funções de conta secundária substituídas pelas versões melhoradas');
        
        // Funções de teste disponíveis
        window.testSecondaryAccountCheck = async () => {
            const isSecondary = await checkIfSecondaryAccountImproved();
            console.log(`📊 RESULTADO: ${isSecondary ? 'É CONTA SECUNDÁRIA' : 'É CONTA PRINCIPAL'}`);
            return isSecondary;
        };
        
        window.diagnoseSecondaryAccountIssue = async () => {
            console.log('🔧 DIAGNÓSTICO DE CONTA SECUNDÁRIA');
            console.log('1. Verificando autenticação...');
            
            const { data: { user }, error: authError } = await supabase.auth.getUser();
            if (authError || !user) {
                console.error('❌ Erro de autenticação:', authError);
                return;
            }
            
            console.log('✅ Usuário autenticado:', user.email);
            console.log('📋 User ID:', user.id);
            
            console.log('2. Verificando tabela secondary_accounts...');
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
                
                console.log('3. Verificando relação do usuário...');
                const { data: relation, error: relError } = await supabase
                    .from('secondary_accounts')
                    .select('primary_account_id')
                    .eq('secondary_account_id', user.id)
                    .single();
                
                if (relError) {
                    if (relError.code === 'PGRST116') {
                        console.log('✅ Usuário NÃO é conta secundária');
                    } else {
                        console.error('❌ Erro ao verificar relação:', relError);
                    }
                } else {
                    console.log('✅ Usuário É conta secundária');
                    console.log('📋 Conta principal ID:', relation.primary_account_id);
                }
                
            } catch (error) {
                console.error('❌ Erro no diagnóstico:', error);
            }
            
            console.log('🔧 DIAGNÓSTICO CONCLUÍDO');
        };
        
        console.log('✅ Funções de teste disponíveis:');
        console.log('   - testSecondaryAccountCheck()');
        console.log('   - diagnoseSecondaryAccountIssue()');
    }
}

// Executar a substituição
replaceSecondaryAccountFunctions();

console.log('✅ MELHORIAS DE CONTA SECUNDÁRIA INCLUÍDAS'); 