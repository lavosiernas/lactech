// MELHORIAS NAS FUNÇÕES DE CARREGAMENTO DE DADOS
// Este script melhora as funções que mostram "Carregando..." para garantir que carreguem dados reais

// Função melhorada para carregar dados do usuário
async function loadUserProfileImproved() {
    try {
        console.log('=== INÍCIO loadUserProfileImproved ===');
        
        // Verificar se os elementos existem
        const elements = {
            email: document.getElementById('profileEmail2'),
            whatsapp: document.getElementById('profileWhatsApp'),
            name: document.getElementById('profileFullName'),
            farmName: document.getElementById('profileFarmName')
        };
        
        // Verificar se todos os elementos existem
        for (const [key, element] of Object.entries(elements)) {
            if (!element) {
                console.error(`❌ Elemento ${key} não encontrado!`);
                return;
            }
        }
        
        console.log('✅ Todos os elementos encontrados');
        
        // Primeiro tentar obter da sessão local
        const sessionData = localStorage.getItem('userData') || sessionStorage.getItem('userData');
        if (sessionData) {
            try {
                const user = JSON.parse(sessionData);
                console.log('📱 Usando dados da sessão:', user);
                
                // Definir dados do perfil da sessão
                elements.email.textContent = user.email || 'Não informado';
                elements.whatsapp.textContent = user.whatsapp || user.phone || 'Não informado';
                elements.name.textContent = user.name || 'Não informado';
                elements.farmName.textContent = user.farm_name || 'Minha Fazenda';
                
                console.log('✅ Dados carregados da sessão');
                return;
            } catch (error) {
                console.error('❌ Erro ao processar dados da sessão:', error);
            }
        }
        
        // Fallback para Supabase Auth
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            console.error('❌ Erro de autenticação:', authError);
            setDefaultValues(elements);
            return;
        }
        
        console.log('👤 Usuário autenticado:', user.email);
        
        // Buscar dados do usuário no banco
        const { data: userData, error: dbError } = await supabase
            .from('users')
            .select('name, email, whatsapp, phone, farm_id')
            .eq('id', user.id)
            .single();
        
        if (dbError) {
            console.error('❌ Erro ao buscar dados do usuário:', dbError);
            
            // Se usuário não encontrado, tentar criar
            if (dbError.code === 'PGRST116') {
                console.log('🔄 Usuário não encontrado, criando...');
                try {
                    await createUserIfNotExists(user);
                    await new Promise(resolve => setTimeout(resolve, 1000));
                    
                    // Tentar novamente após criar
                    const { data: retryData, error: retryError } = await supabase
                        .from('users')
                        .select('name, email, whatsapp, phone, farm_id')
                        .eq('id', user.id)
                        .single();
                    
                    if (retryError) {
                        console.error('❌ Erro na segunda tentativa:', retryError);
                        setDefaultValues(elements, user);
                        return;
                    }
                    
                    updateProfileElements(elements, retryData, user);
                    await loadFarmName(elements, retryData.farm_id);
                    return;
                } catch (createError) {
                    console.error('❌ Erro ao criar usuário:', createError);
                    setDefaultValues(elements, user);
                    return;
                }
            }
            
            setDefaultValues(elements, user);
            return;
        }
        
        // Atualizar elementos com dados do banco
        updateProfileElements(elements, userData, user);
        
        // Carregar nome da fazenda se farm_id estiver disponível
        if (userData?.farm_id) {
            await loadFarmName(elements, userData.farm_id);
        }
        
        console.log('✅ Dados do perfil carregados com sucesso');
        
    } catch (error) {
        console.error('❌ Erro geral em loadUserProfileImproved:', error);
        setDefaultValues(elements);
    }
}

// Função para definir valores padrão
function setDefaultValues(elements, user = null) {
    const email = user?.email || 'Não informado';
    const name = user?.user_metadata?.name || user?.email?.split('@')[0] || 'Usuário';
    
    elements.email.textContent = email;
    elements.whatsapp.textContent = 'Não informado';
    elements.name.textContent = name;
    elements.farmName.textContent = 'Minha Fazenda';
    
    console.log('📝 Valores padrão definidos');
}

// Função para atualizar elementos do perfil
function updateProfileElements(elements, userData, authUser) {
    const email = userData?.email || authUser?.email || 'Não informado';
    const whatsapp = userData?.whatsapp || userData?.phone || 'Não informado';
    const name = userData?.name || authUser?.user_metadata?.name || authUser?.email?.split('@')[0] || 'Usuário';
    
    elements.email.textContent = email;
    elements.whatsapp.textContent = whatsapp;
    elements.name.textContent = name;
    
    console.log('📝 Elementos atualizados:', { email, whatsapp, name });
}

// Função para carregar nome da fazenda
async function loadFarmName(elements, farmId) {
    try {
        if (!farmId) {
            console.log('⚠️ Farm ID não disponível');
            return;
        }
        
        const { data: farmData, error } = await supabase
            .from('farms')
            .select('name')
            .eq('id', farmId)
            .single();
        
        if (error) {
            console.error('❌ Erro ao carregar nome da fazenda:', error);
            return;
        }
        
        if (farmData?.name) {
            elements.farmName.textContent = farmData.name;
            console.log('🏡 Nome da fazenda carregado:', farmData.name);
        }
        
    } catch (error) {
        console.error('❌ Erro ao carregar nome da fazenda:', error);
    }
}

// Função melhorada para carregar nome da fazenda no header
async function setFarmNameImproved() {
    try {
        console.log('🏡 Carregando nome da fazenda...');
        
        // Primeiro tentar da sessão
        const userData = localStorage.getItem('userData') || sessionStorage.getItem('userData');
        if (userData) {
            try {
                const user = JSON.parse(userData);
                if (user.farm_name) {
                    const element = document.getElementById('farmNameHeader');
                    if (element) {
                        element.textContent = user.farm_name;
                        console.log('✅ Nome da fazenda da sessão:', user.farm_name);
                        return;
                    }
                }
            } catch (error) {
                console.error('❌ Erro ao processar dados da sessão:', error);
            }
        }
        
        // Buscar do banco
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.log('⚠️ Usuário não autenticado');
            return;
        }
        
        const { data: userDbData, error: userError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('email', user.email)
            .maybeSingle();
        
        if (userError) {
            console.error('❌ Erro ao buscar dados do usuário:', userError);
            return;
        }
        
        if (!userDbData?.farm_id) {
            console.log('⚠️ Farm ID não encontrado');
            return;
        }
        
        const { data: farmData, error: farmError } = await supabase
            .from('farms')
            .select('name')
            .eq('id', userDbData.farm_id)
            .single();
        
        if (farmError || !farmData?.name) {
            console.error('❌ Erro ao buscar nome da fazenda:', farmError);
            return;
        }
        
        const element = document.getElementById('farmNameHeader');
        if (element) {
            element.textContent = farmData.name;
            console.log('✅ Nome da fazenda carregado:', farmData.name);
        }
        
    } catch (error) {
        console.error('❌ Erro em setFarmNameImproved:', error);
    }
}

// Função melhorada para carregar nome do gerente
async function setManagerNameImproved() {
    try {
        console.log('👤 Carregando nome do gerente...');
        
        // Primeiro tentar da sessão
        const userData = localStorage.getItem('userData') || sessionStorage.getItem('userData');
        if (userData) {
            try {
                const user = JSON.parse(userData);
                if (user.name) {
                    updateManagerElements(user.name);
                    console.log('✅ Nome do gerente da sessão:', user.name);
                    return;
                }
            } catch (error) {
                console.error('❌ Erro ao processar dados da sessão:', error);
            }
        }
        
        // Buscar do banco
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            console.log('⚠️ Usuário não autenticado');
            return;
        }
        
        const { data: userData, error } = await supabase
            .from('users')
            .select('name')
            .eq('id', user.id)
            .single();
        
        if (error) {
            console.error('❌ Erro ao buscar dados do usuário:', error);
            const fallbackName = user.user_metadata?.name || user.email?.split('@')[0] || 'Gerente';
            updateManagerElements(fallbackName);
            return;
        }
        
        const managerName = userData?.name || user.user_metadata?.name || user.email?.split('@')[0] || 'Gerente';
        updateManagerElements(managerName);
        console.log('✅ Nome do gerente carregado:', managerName);
        
    } catch (error) {
        console.error('❌ Erro em setManagerNameImproved:', error);
        updateManagerElements('Gerente');
    }
}

// Função para atualizar elementos do gerente
function updateManagerElements(managerName) {
    const elements = [
        'managerName',
        'managerWelcome',
        'profileName',
        'profileFullName'
    ];
    
    for (const elementId of elements) {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = managerName;
        }
    }
    
    console.log('📝 Elementos do gerente atualizados:', managerName);
}

// Função para substituir as funções originais
function replaceOriginalFunctions() {
    // Substituir funções originais pelas melhoradas
    if (typeof window !== 'undefined') {
        window.loadUserProfile = loadUserProfileImproved;
        window.setFarmName = setFarmNameImproved;
        window.setManagerName = setManagerNameImproved;
        
        console.log('✅ Funções originais substituídas pelas melhoradas');
    }
}

// Executar a substituição
replaceOriginalFunctions(); 