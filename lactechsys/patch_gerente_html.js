/**
 * Este script contém a função corrigida saveSecondaryAccount para substituir
 * no arquivo gerente.html. A função foi modificada para usar um email diferente
 * para a conta secundária, contornando a restrição de unicidade.
 * 
 * Para aplicar esta correção:
 * 1. Abra o arquivo gerente.html
 * 2. Localize a função saveSecondaryAccount (aproximadamente linha 6200)
 * 3. Substitua toda a função pelo código abaixo
 */

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
        const { data: existingAccounts, error: existingError } = await supabase
            .from('users')
            .select('*')
            .eq('farm_id', userData.farm_id)
            .eq('role', secondaryRole)
            .ilike('email', userData.email.replace('@', '+secondary@'))
            .maybeSingle();
            
        let secondaryAccount;
        
        if (!existingError && existingAccounts) {
            // Update existing secondary account
            const { data: updatedAccount, error: updateError } = await supabase
                .from('users')
                .update({
                    name: secondaryName,
                    is_active: isActive
                })
                .eq('id', existingAccounts.id)
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
            
            // SOLUÇÃO: Gerar um email modificado para a conta secundária
            // Adiciona +secondary ao email antes do @ para manter a entrega no mesmo endereço
            // mas contornar a restrição de unicidade no banco de dados
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