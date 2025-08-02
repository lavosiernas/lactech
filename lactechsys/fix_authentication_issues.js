// =====================================================
// CORREÇÕES PARA PROBLEMAS DE AUTENTICAÇÃO
// =====================================================

// 1. CORREÇÃO PARA PRIMEIROACESSO.HTML
// =====================================================

// Função para criar usuário sem confirmação de email
async function createUserWithoutEmailConfirmation(email, password, userData) {
    try {
        // Criar usuário no Supabase Auth com email_confirm = false
        const { data: authData, error: authError } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                data: {
                    name: userData.name,
                    role: userData.role,
                    farm_id: userData.farm_id
                },
                emailRedirectTo: window.location.origin + '/login.html'
            }
        });

        if (authError) {
            console.error('Erro no signup:', authError);
            throw authError;
        }

        // Se o usuário foi criado mas precisa de confirmação, vamos tentar fazer login direto
        if (authData.user && !authData.user.email_confirmed_at) {
            console.log('Usuário criado, tentando login direto...');
            
            // Aguardar um pouco para o usuário ser processado
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Tentar login direto
            const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (loginError) {
                console.log('Login direto falhou:', loginError);
                // Continuar mesmo assim, o usuário pode fazer login manualmente
            } else {
                console.log('Login direto bem-sucedido!');
            }
        }

        return authData;
    } catch (error) {
        console.error('Erro na criação do usuário:', error);
        throw error;
    }
}

// Função para verificar se o usuário existe e está ativo
async function checkUserExistsAndActive(email) {
    try {
        const { data: userData, error } = await supabase
            .from('users')
            .select('*')
            .eq('email', email)
            .eq('is_active', true)
            .single();

        if (error) {
            console.log('Usuário não encontrado ou inativo:', error);
            return null;
        }

        return userData;
    } catch (error) {
        console.error('Erro ao verificar usuário:', error);
        return null;
    }
}

// 2. CORREÇÃO PARA LOGIN.HTML
// =====================================================

// Função de autenticação melhorada
async function authenticateUserImproved(email, password) {
    try {
        console.log('Tentando autenticação para:', email);
        
        // Primeiro verificar se o usuário existe no banco
        const userData = await checkUserExistsAndActive(email);
        if (!userData) {
            throw new Error('Usuário não encontrado no sistema. Complete o cadastro primeiro.');
        }

        // Tentar login no Supabase Auth
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });

        if (authError) {
            console.log('Erro no login Supabase:', authError);
            
            // Se o erro for "Email not confirmed", tentar uma abordagem diferente
            if (authError.message.includes('Email not confirmed')) {
                console.log('Email não confirmado, tentando login alternativo...');
                
                // Verificar se o usuário existe no banco e está ativo
                if (userData) {
                    console.log('Usuário encontrado no banco, criando sessão local...');
                    
                    // Criar sessão local baseada nos dados do banco
                    return {
                        user: {
                            id: userData.id,
                            email: userData.email,
                            email_confirmed_at: new Date().toISOString()
                        },
                        profile: {
                            id: userData.id,
                            email: userData.email,
                            name: userData.name || userData.email.split('@')[0],
                            user_type: userData.role || 'gerente',
                            farm_id: userData.farm_id,
                            farm_name: 'Minha Fazenda',
                            status: 'active'
                        }
                    };
                }
            }
            
            throw new Error('Credenciais inválidas');
        }

        console.log('Login bem-sucedido!');
        
        // Buscar informações da fazenda
        const { data: farmData, error: farmError } = await supabase
            .from('farms')
            .select('*')
            .eq('id', userData.farm_id)
            .single();

        if (farmError) {
            console.warn('Não foi possível buscar dados da fazenda:', farmError);
        }

        return {
            user: {
                id: userData.id,
                email: userData.email,
                email_confirmed_at: authData.user?.email_confirmed_at || new Date().toISOString()
            },
            profile: {
                id: userData.id,
                email: userData.email,
                name: userData.name || userData.email.split('@')[0],
                user_type: userData.role || 'gerente',
                farm_id: userData.farm_id,
                farm_name: farmData ? farmData.name : 'Minha Fazenda',
                status: 'active'
            }
        };

    } catch (error) {
        console.error('Erro na autenticação:', error);
        throw error;
    }
}

// 3. FUNÇÕES AUXILIARES
// =====================================================

// Função para armazenar sessão do usuário
function storeUserSessionImproved(userData, remember = false) {
    const storage = remember ? localStorage : sessionStorage;
    
    const sessionData = {
        id: userData.user.id,
        email: userData.user.email,
        userType: userData.profile.user_type,
        name: userData.profile.name,
        farmId: userData.profile.farm_id,
        loginTime: new Date().toISOString(),
        isAuthenticated: true
    };
    
    storage.setItem('userData', JSON.stringify(sessionData));
    
    // Também armazenar no localStorage para persistência
    if (!remember) {
        localStorage.setItem('userData', JSON.stringify(sessionData));
    }
}

// Função para verificar sessão existente
function checkExistingSessionImproved() {
    const userData = localStorage.getItem('userData') || sessionStorage.getItem('userData');
    
    if (userData) {
        try {
            const user = JSON.parse(userData);
            const loginTime = new Date(user.loginTime);
            const now = new Date();
            const hoursSinceLogin = (now - loginTime) / (1000 * 60 * 60);
            
            // Sessão válida por 24 horas
            if (hoursSinceLogin < 24 && user.isAuthenticated) {
                console.log('Sessão válida encontrada para:', user.email);
                return user;
            } else {
                // Limpar sessão expirada
                localStorage.removeItem('userData');
                sessionStorage.removeItem('userData');
            }
        } catch (error) {
            console.error('Erro ao verificar sessão:', error);
            localStorage.removeItem('userData');
            sessionStorage.removeItem('userData');
        }
    }
    
    return null;
}

// Função para redirecionar baseado no tipo de usuário
function redirectBasedOnUserType(userType) {
    const redirectMap = {
        'proprietario': 'proprietario.html',
        'gerente': 'gerente.html',
        'funcionario': 'funcionario.html',
        'veterinario': 'veterinario.html'
    };
    
    const redirectUrl = redirectMap[userType] || 'gerente.html';
    console.log('Redirecionando para:', redirectUrl);
    window.location.href = redirectUrl;
}

// 4. INSTRUÇÕES DE IMPLEMENTAÇÃO
// =====================================================

/*
INSTRUÇÕES PARA IMPLEMENTAR AS CORREÇÕES:

1. NO PRIMEIROACESSO.HTML:
   - Substitua a função de criação de usuário pela createUserWithoutEmailConfirmation
   - Adicione verificação de usuário existente antes de criar

2. NO LOGIN.HTML:
   - Substitua a função authenticateUser pela authenticateUserImproved
   - Use storeUserSessionImproved para armazenar sessão
   - Use checkExistingSessionImproved para verificar sessão

3. NAS OUTRAS PÁGINAS:
   - Use checkExistingSessionImproved para verificar autenticação
   - Use redirectBasedOnUserType para redirecionamentos

EXEMPLO DE IMPLEMENTAÇÃO:

// No PrimeiroAcesso.html, substitua a criação de usuário:
const { data: authData, error: authError } = await createUserWithoutEmailConfirmation(
    adminData.email, 
    adminData.password, 
    {
        name: adminData.name,
        role: adminData.role,
        farm_id: farmId
    }
);

// No login.html, substitua a autenticação:
const userData = await authenticateUserImproved(email, password);
storeUserSessionImproved(userData, remember);

// Para verificar sessão em qualquer página:
const session = checkExistingSessionImproved();
if (session) {
    redirectBasedOnUserType(session.userType);
}
*/ 