/**
 * Script para testar a criação de contas secundárias
 * Execute este script no console do navegador
 */

async function testSecondaryAccountCreation() {
    console.log('🧪 Testando criação de conta secundária...');
    
    try {
        // 1. Verificar usuário atual
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.error('❌ Usuário não autenticado');
            return;
        }
        
        console.log('✅ Usuário autenticado:', user.email);
        
        // 2. Obter dados do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .single();
            
        if (userError) {
            console.error('❌ Erro ao obter dados do usuário:', userError);
            return;
        }
        
        console.log('✅ Dados do usuário obtidos:', userData.name);
        
        // 3. Gerar email para conta secundária
        const secondaryEmail = userData.email + '.func';
        console.log('📧 Email secundário gerado:', secondaryEmail);
        
        // 4. Verificar se já existe conta secundária
        const { data: existingAccount, error: checkError } = await supabase
            .from('users')
            .select('*')
            .eq('email', secondaryEmail)
            .eq('farm_id', userData.farm_id)
            .maybeSingle();
            
        if (checkError) {
            console.error('❌ Erro ao verificar conta existente:', checkError);
            return;
        }
        
        if (existingAccount) {
            console.log('⚠️ Conta secundária já existe:', existingAccount.name);
            console.log('📊 Dados da conta existente:', existingAccount);
            return;
        }
        
        // 5. Simular criação de conta secundária
        console.log('🔄 Simulando criação de conta secundária...');
        
        const testSecondaryAccount = {
            id: crypto.randomUUID(),
            farm_id: userData.farm_id,
            name: userData.name + ' (Funcionário)',
            email: secondaryEmail,
            role: 'funcionario',
            whatsapp: userData.whatsapp,
            is_active: true,
            profile_photo_url: userData.profile_photo_url
        };
        
        console.log('📋 Dados da conta secundária:', testSecondaryAccount);
        
        // 6. Testar inserção (sem executar)
        console.log('✅ Simulação concluída - dados prontos para inserção');
        console.log('💡 Para criar a conta real, use o formulário do sistema');
        
        // 7. Verificar restrições
        console.log('\n🔍 Verificando restrições de email...');
        const { data: allUsers, error: allUsersError } = await supabase
            .from('users')
            .select('email, farm_id, name, role')
            .eq('farm_id', userData.farm_id);
            
        if (allUsersError) {
            console.error('❌ Erro ao verificar usuários:', allUsersError);
        } else {
            console.log('📊 Usuários na mesma fazenda:', allUsers);
            
            // Verificar se há emails duplicados
            const emails = allUsers.map(u => u.email);
            const duplicateEmails = emails.filter((email, index) => emails.indexOf(email) !== index);
            
            if (duplicateEmails.length > 0) {
                console.warn('⚠️ Emails duplicados encontrados:', duplicateEmails);
            } else {
                console.log('✅ Nenhum email duplicado encontrado');
            }
        }
        
        console.log('\n🎉 Teste concluído!');
        console.log('📝 Para criar uma conta secundária real:');
        console.log('1. Vá para o perfil do usuário');
        console.log('2. Clique em "Configurar" na seção Conta Secundária');
        console.log('3. Preencha os dados e salve');
        
    } catch (error) {
        console.error('❌ Erro no teste:', error);
    }
}

// Função para verificar contas secundárias existentes
async function checkExistingSecondaryAccounts() {
    console.log('🔍 Verificando contas secundárias existentes...');
    
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;
        
        const { data: userData } = await supabase
            .from('users')
            .select('farm_id, email')
            .eq('id', user.id)
            .single();
            
        if (!userData) return;
        
        // Buscar contas secundárias (emails modificados)
        const { data: secondaryAccounts, error } = await supabase
            .from('users')
            .select('*')
            .eq('farm_id', userData.farm_id)
            .or(`email.eq.${userData.email}.func,email.eq.${userData.email}.vet`);
            
        if (error) {
            console.error('❌ Erro ao buscar contas secundárias:', error);
        } else {
            console.log('📊 Contas secundárias encontradas:', secondaryAccounts);
        }
        
    } catch (error) {
        console.error('❌ Erro ao verificar contas secundárias:', error);
    }
}

// Exportar funções
window.testSecondaryAccountCreation = testSecondaryAccountCreation;
window.checkExistingSecondaryAccounts = checkExistingSecondaryAccounts;

console.log('🧪 Script de teste de conta secundária carregado!');
console.log('Comandos disponíveis:');
console.log('- testSecondaryAccountCreation() - Testar criação de conta secundária');
console.log('- checkExistingSecondaryAccounts() - Verificar contas secundárias existentes'); 