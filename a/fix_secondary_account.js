/**
 * Solução para o problema de criação de contas secundárias
 * 
 * Este script contém uma função modificada para criar contas secundárias
 * que contorna o problema da restrição UNIQUE no campo email da tabela users.
 * 
 * O problema ocorre porque a tabela users tem uma restrição UNIQUE no campo email,
 * mas o código está tentando criar uma conta secundária com o mesmo email da conta principal.
 * 
 * Existem duas soluções possíveis:
 * 
 * 1. Modificar a estrutura do banco de dados (recomendado):
 *    - Execute o script SQL fix_email_constraint.sql para remover a restrição UNIQUE
 *      do campo email e adicionar uma restrição composta para email, farm_id e id.
 * 
 * 2. Modificar o código para usar emails diferentes (alternativa):
 *    - Substitua a função saveSecondaryAccount no arquivo gerente.html pelo código abaixo
 *    - Esta solução gera um email único para a conta secundária baseado no email principal
 */

// Função modificada para salvar conta secundária
async function saveSecondaryAccount(event) {
    event.preventDefault();
    
    try {
        // Desabilitar o botão durante o processamento
        const submitBtn = event.target.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="loading-spinner mr-2"></span> Salvando...';
        
        // Obter dados do formulário
        const secondaryName = document.getElementById('secondaryName').value;
        const secondaryRole = document.getElementById('secondaryRole').value;
        const isActive = document.getElementById('secondaryIsActive').checked;
        
        // Obter dados do usuário atual
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            alert('Usuário não autenticado. Por favor, faça login novamente.');
            return;
        }
        
        // Obter dados completos do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .single();
            
        if (userError) {
            console.error('Erro ao obter dados do usuário:', userError);
            alert('Erro ao obter dados do usuário. Por favor, tente novamente.');
            return;
        }
        
        // Verificar se já existe uma conta secundária
        const { data: existingAccount, error: existingError } = await supabase
            .from('secondary_accounts')
            .select('*')
            .eq('primary_account_id', userData.id)
            .maybeSingle();
            
        let secondaryAccount;
        
        if (!existingError && existingAccount) {
            // Update existing secondary account
            const { data: updatedAccount, error: updateError } = await supabase
                .from('secondary_accounts')
                .update({
                    name: secondaryName,
                    role: secondaryRole,
                    is_active: isActive
                })
                .eq('id', existingAccount.id)
                .select()
                .single();
                
            if (updateError) {
                console.error('Erro ao atualizar conta secundária:', updateError);
                alert('Erro ao atualizar conta secundária. Por favor, tente novamente.');
                return;
            }
            
            secondaryAccount = updatedAccount;
            showNotification('Conta secundária atualizada com sucesso!', 'success');
        } else {
            // Create new secondary account
            console.log('Criando nova conta secundária com dados:', {
                farm_id: userData.farm_id,
                name: secondaryName,
                email: userData.email,
                role: secondaryRole,
                whatsapp: userData.whatsapp,
                is_active: isActive,
                profile_photo_url: userData.profile_photo_url
            });
            
            // Primeiro, verificar se já existe um usuário com o mesmo email e farm_id
            const { data: existingUsers, error: existingError } = await supabase
                .from('users')
                .select('*')
                .eq('email', userData.email)
                .eq('farm_id', userData.farm_id)
                .neq('id', userData.id);
                
            if (existingError) {
                console.error('Erro ao verificar usuários existentes:', existingError);
            } else {
                console.log('Usuários existentes com mesmo email e farm_id:', existingUsers);
                
                // Se já existir um usuário secundário, atualizar em vez de criar
                if (existingUsers && existingUsers.length > 0) {
                    const { data: updatedAccount, error: updateError } = await supabase
                        .from('users')
                        .update({
                            name: secondaryName,
                            role: secondaryRole,
                            is_active: isActive
                        })
                        .eq('id', existingUsers[0].id)
                        .select()
                        .single();
                        
                    if (updateError) {
                        console.error('Erro ao atualizar conta secundária existente:', updateError);
                        alert('Erro ao atualizar conta secundária. Por favor, tente novamente.');
                        return;
                    }
                    
                    secondaryAccount = updatedAccount;
                    showNotification('Conta secundária atualizada com sucesso!', 'success');
                    
                    // Atualizar a interface e sair da função
                    document.getElementById('noSecondaryAccount').style.display = 'none';
                    document.getElementById('hasSecondaryAccount').style.display = 'block';
                    document.getElementById('secondaryAccountNameDisplay').textContent = secondaryAccount.name;
                    document.getElementById('switchAccountBtn').disabled = false;
                    hideSecondaryAccountForm();
                    return;
                }
            }
            
            // SOLUÇÃO ALTERNATIVA: Gerar um email modificado para a conta secundária
            // Esta solução só é necessária se não for possível modificar a estrutura do banco de dados
            const secondaryEmail = userData.email.replace('@', '+secondary@');
            
            // Gerar um novo UUID para o usuário secundário
            const newUserId = crypto.randomUUID();
            console.log('Novo UUID gerado para conta secundária:', newUserId);
            
            const { data: newAccount, error: createError } = await supabase
                .from('users')
                .insert([
                    {
                        id: newUserId,
                        farm_id: userData.farm_id,
                        name: secondaryName,
                        email: secondaryEmail, // Usar o email modificado
                        role: secondaryRole,
                        whatsapp: userData.whatsapp,
                        is_active: isActive,
                        profile_photo_url: userData.profile_photo_url
                    }
                ])
                .select()
                .single();
                
            if (createError) {
                console.error('Erro ao criar conta secundária:', createError);
                alert('Erro ao criar conta secundária. Por favor, tente novamente.');
                return;
            }
            
            // Registrar a relação entre conta principal e secundária
            const { error: relationError } = await supabase
                .from('secondary_accounts')
                .insert([
                    {
                        primary_account_id: userData.id,
                        secondary_account_id: newUserId
                    }
                ]);
                
            if (relationError) {
                console.error('Erro ao registrar relação de contas:', relationError);
                // Não impedir o fluxo se este erro ocorrer
            }
            
            secondaryAccount = newAccount;
            showNotification('Conta secundária criada com sucesso!', 'success');
        }
        
        // Atualizar o status da conta secundária
        document.getElementById('noSecondaryAccount').style.display = 'none';
        document.getElementById('hasSecondaryAccount').style.display = 'block';
        document.getElementById('secondaryAccountNameDisplay').textContent = secondaryAccount.name;
        
        // Habilitar o botão de alternar
        document.getElementById('switchAccountBtn').disabled = false;
        
        // Esconder o formulário
        hideSecondaryAccountForm();
        
    } catch (error) {
        console.error('Erro ao salvar conta secundária:', error);
        alert('Ocorreu um erro ao salvar a conta secundária.');
    } finally {
        // Restaurar o botão
        const submitBtn = event.target.querySelector('button[type="submit"]');
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Salvar';
    }
}