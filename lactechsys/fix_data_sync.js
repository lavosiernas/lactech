// Correções para sincronização de dados entre funcionário e gerente
// Este arquivo contém as funções corrigidas para resolver o problema de dados não aparecendo entre as páginas

// PROBLEMA IDENTIFICADO:
// - Página do funcionário filtra dados por user_id (apenas registros do próprio funcionário)
// - Página do gerente filtra dados por farm_id (todos os registros da fazenda)
// - Isso causa inconsistência: registros do gerente não aparecem para funcionário e vice-versa

// SOLUÇÃO:
// - Ambas as páginas devem mostrar todos os registros da fazenda (filtrar por farm_id)
// - Manter a identificação de quem criou cada registro (user_id) para auditoria

// ===== CORREÇÕES PARA FUNCIONARIO.HTML =====

// Função corrigida para loadDashboardIndicators
async function loadDashboardIndicators_FIXED() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        // Buscar farm_id do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('id', user.id)
            .single();

        if (userError) throw userError;

        const now = new Date();
        const today = formatLocalDate(now);

        // CORREÇÃO: Filtrar por farm_id em vez de user_id
        const { data: todayData, error: todayError } = await supabase
            .from('milk_production')
            .select('volume_liters')
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .eq('production_date', today);

        if (todayError) throw todayError;

        // Calcular volume total de hoje
        const todayVolume = todayData && todayData.length > 0 
            ? todayData.reduce((sum, record) => sum + record.volume_liters, 0).toFixed(1)
            : '0.0';
        const todayVolumeElement = document.getElementById('todayVolume');
        if (todayVolumeElement) {
            todayVolumeElement.textContent = `${todayVolume}L`;
        }

        // Dados do mês atual
        const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const { data: monthData, error: monthError } = await supabase
            .from('milk_production')
            .select('volume_liters, production_date')
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .gte('production_date', formatLocalDate(firstDayOfMonth));

        if (monthError) throw monthError;

        // Média semanal (últimos 7 dias)
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
        const { data: weekData, error: weekError } = await supabase
            .from('milk_production')
            .select('volume_liters, production_date')
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .gte('production_date', formatLocalDate(sevenDaysAgo));

        if (weekError) throw weekError;

        // Calcular totais diários da semana
        const weeklyDailyTotals = {};
        if (weekData) {
            weekData.forEach(record => {
                const date = record.production_date;
                if (!weeklyDailyTotals[date]) {
                    weeklyDailyTotals[date] = 0;
                }
                weeklyDailyTotals[date] += record.volume_liters;
            });
        }

        // Calcular média dos totais diários
        const dailyTotalValues = Object.values(weeklyDailyTotals);
        const weeklyAverage = dailyTotalValues.length > 0 
            ? (dailyTotalValues.reduce((sum, total) => sum + total, 0) / dailyTotalValues.length).toFixed(1)
            : '0.0';
        const weeklyAverageElement = document.getElementById('weekAverage');
        if (weeklyAverageElement) {
            weeklyAverageElement.textContent = `${weeklyAverage}L`;
        }

        // Calcular melhor dia do mês
        const dailyTotals = {};
        if (monthData) {
            monthData.forEach(record => {
                const date = record.production_date;
                if (!dailyTotals[date]) {
                    dailyTotals[date] = 0;
                }
                dailyTotals[date] += record.volume_liters;
            });
        }

        const bestDayVolume = Object.keys(dailyTotals).length > 0 
            ? Math.max(...Object.values(dailyTotals)).toFixed(1)
            : '0.0';
        const bestDayElement = document.getElementById('bestDay');
        if (bestDayElement) {
            bestDayElement.textContent = `${bestDayVolume}L`;
        }

        // Atualizar total de registros do mês
        const totalRecords = monthData ? monthData.length : 0;
        const totalRecordsElement = document.getElementById('totalRecords');
        if (totalRecordsElement) {
            totalRecordsElement.textContent = totalRecords.toString();
        }

    } catch (error) {
        console.error('Error loading dashboard indicators:', error);
    }
}

// Função corrigida para loadRecentActivity
async function loadRecentActivity_FIXED() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        // Buscar farm_id do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('id', user.id)
            .single();

        if (userError) throw userError;

        // CORREÇÃO: Filtrar por farm_id e incluir informações do usuário
        const { data: recentData, error } = await supabase
            .from('milk_production')
            .select(`
                volume_liters, 
                production_date, 
                shift, 
                created_at,
                users!inner(name)
            `)
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .order('production_date', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(5);

        if (error) {
            console.error('Error loading recent activity:', error);
            return;
        }

        const activityList = document.getElementById('activityList');
        if (!activityList) return;

        if (!recentData || recentData.length === 0) {
            activityList.innerHTML = '<p class="text-gray-500 text-sm">Nenhuma atividade recente</p>';
            return;
        }

        activityList.innerHTML = recentData.map(record => {
            const date = new Date(record.created_at);
            const timeAgo = getTimeAgo(date);
            const formattedTime = date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
            const shiftText = {
                'manha': 'Manhã',
                'tarde': 'Tarde', 
                'noite': 'Noite'
            }[record.shift] || record.shift;
            const userName = record.users?.name || 'Usuário';
            
            return `
                <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
                    <div>
                        <p class="text-sm font-medium text-gray-900">${record.volume_liters}L - ${shiftText}</p>
                        <p class="text-xs text-gray-500">${userName} • ${timeAgo}</p>
                    </div>
                    <div class="text-xs text-gray-400">
                        ${formattedTime}
                    </div>
                </div>
            `;
        }).join('');

    } catch (error) {
        console.error('Error loading recent activity:', error);
    }
}

// Função corrigida para loadProductionChart
async function loadProductionChart_FIXED() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        // Buscar farm_id do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('id', user.id)
            .single();

        if (userError) throw userError;

        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
        sevenDaysAgo.setHours(0,0,0,0);

        // CORREÇÃO: Filtrar por farm_id
        const { data: chartData, error } = await supabase
            .from('milk_production')
            .select('volume_liters, production_date')
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .gte('production_date', formatLocalDate(sevenDaysAgo))
            .order('production_date', { ascending: true });

        if (error) {
            console.error('Error loading chart data:', error);
            return;
        }

        // Resto da função permanece igual...
        // (código do gráfico)

    } catch (error) {
        console.error('Error loading production chart:', error);
    }
}

// Função corrigida para refreshHistory
async function refreshHistory_FIXED() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        // Buscar farm_id do usuário
        const { data: userData, error: userError } = await supabase
            .from('users')
            .select('farm_id')
            .eq('id', user.id)
            .single();

        if (userError) throw userError;

        const filter = document.getElementById('historyFilter').value;
        // CORREÇÃO: Filtrar por farm_id e incluir informações do usuário
        let query = supabase
            .from('milk_production')
            .select(`
                *,
                users!inner(name)
            `)
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .order('production_date', { ascending: false })
            .order('created_at', { ascending: false });

        // Aplicar filtro de data
        const now = new Date();
        switch (filter) {
            case 'today':
                const today = formatLocalDate(now);
                query = query.eq('production_date', today);
                break;
            case 'week':
                const weekAgo = new Date();
                weekAgo.setDate(weekAgo.getDate() - 7);
                query = query.gte('production_date', formatLocalDate(weekAgo));
                break;
            case 'month':
                const monthAgo = new Date();
                monthAgo.setMonth(monthAgo.getMonth() - 1);
                query = query.gte('production_date', formatLocalDate(monthAgo));
                break;
            case 'custom':
                const startDate = document.getElementById('startDate').value;
                const endDate = document.getElementById('endDate').value;
                if (startDate && endDate) {
                    query = query.gte('production_date', startDate).lte('production_date', endDate);
                }
                break;
        }

        const { data, error } = await query;

        if (error) throw error;

        // Ordenar dados por data e turno
        const sortedData = data?.sort((a, b) => {
            const dateCompare = new Date(b.production_date) - new Date(a.production_date);
            if (dateCompare !== 0) return dateCompare;
            
            const shiftOrder = { 'manha': 1, 'tarde': 2, 'noite': 3 };
            return (shiftOrder[a.shift] || 4) - (shiftOrder[b.shift] || 4);
        });

        displayHistory(sortedData);

    } catch (error) {
        console.error('Error refreshing history:', error);
    }
}

// ===== INSTRUÇÕES DE IMPLEMENTAÇÃO =====

/*
PARA IMPLEMENTAR AS CORREÇÕES:

1. FUNCIONARIO.HTML:
   - Substituir a função loadDashboardIndicators pela versão _FIXED
   - Substituir a função loadRecentActivity pela versão _FIXED
   - Substituir a função loadProductionChart pela versão _FIXED
   - Substituir a função refreshHistory pela versão _FIXED

2. GERENTE.HTML:
   - As funções já estão corretas (filtram por farm_id)
   - Apenas verificar se todas as consultas usam farm_id

3. PRINCIPAIS MUDANÇAS:
   - Todas as consultas na página do funcionário agora filtram por farm_id
   - Adicionado JOIN com tabela users para mostrar quem criou cada registro
   - Mantido user_id nos registros para auditoria

4. RESULTADO ESPERADO:
   - Funcionário verá todos os registros da fazenda (seus + do gerente)
   - Gerente verá todos os registros da fazenda (seus + dos funcionários)
   - Indicadores serão calculados com base em todos os registros da fazenda
   - Histórico mostrará todos os registros com identificação do criador
*/