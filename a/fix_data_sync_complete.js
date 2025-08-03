// =====================================================
// CORREÇÃO COMPLETA DA SINCRONIZAÇÃO DE DADOS - LACTECH
// Este arquivo resolve o problema de dados não aparecendo entre funcionário e gerente
// =====================================================

// PROBLEMA IDENTIFICADO:
// - Página do funcionário filtra dados por user_id (apenas registros do próprio funcionário)
// - Página do gerente filtra dados por farm_id (todos os registros da fazenda)
// - Isso causa inconsistência: registros do gerente não aparecem para funcionário e vice-versa

// SOLUÇÃO:
// - Ambas as páginas devem mostrar todos os registros da fazenda (filtrar por farm_id)
// - Manter a identificação de quem criou cada registro (user_id) para auditoria

// =====================================================
// FUNÇÕES CORRIGIDAS PARA FUNCIONARIO.HTML
// =====================================================

/**
 * Carregar indicadores do dashboard (CORRIGIDO)
 */
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

        const bestDay = Object.entries(dailyTotals).reduce((best, [date, volume]) => {
            return volume > best.volume ? { date, volume } : best;
        }, { date: null, volume: 0 });

        const bestDayElement = document.getElementById('bestDay');
        if (bestDayElement && bestDay.date) {
            const bestDate = new Date(bestDay.date);
            bestDayElement.textContent = `${bestDay.volume.toFixed(1)}L (${bestDate.toLocaleDateString('pt-BR')})`;
        }

        // Total do mês
        const monthTotal = monthData && monthData.length > 0 
            ? monthData.reduce((sum, record) => sum + record.volume_liters, 0).toFixed(1)
            : '0.0';
        const monthTotalElement = document.getElementById('monthTotal');
        if (monthTotalElement) {
            monthTotalElement.textContent = `${monthTotal}L`;
        }

    } catch (error) {
        console.error('Erro ao carregar indicadores:', error);
    }
}

/**
 * Carregar atividade recente (CORRIGIDO)
 */
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

        // CORREÇÃO: Filtrar por farm_id em vez de user_id
        const { data: recentData, error } = await supabase
            .from('milk_production')
            .select(`
                volume_liters, 
                production_date, 
                shift, 
                created_at,
                users(name)
            `)
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .order('production_date', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(5);

        if (error) throw error;

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
        console.error('Erro ao carregar atividade recente:', error);
    }
}

/**
 * Carregar gráfico de produção (CORRIGIDO)
 */
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

        // Buscar dados dos últimos 7 dias
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);

        // CORREÇÃO: Filtrar por farm_id em vez de user_id
        const { data: chartData, error } = await supabase
            .from('milk_production')
            .select('volume_liters, production_date, shift')
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .gte('production_date', formatLocalDate(sevenDaysAgo))
            .order('production_date', { ascending: true });

        if (error) throw error;

        // Processar dados para o gráfico
        const dailyTotals = {};
        if (chartData) {
            chartData.forEach(record => {
                const date = record.production_date;
                if (!dailyTotals[date]) {
                    dailyTotals[date] = 0;
                }
                dailyTotals[date] += record.volume_liters;
            });
        }

        // Criar arrays para o gráfico
        const labels = [];
        const data = [];

        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateStr = formatLocalDate(date);
            labels.push(date.toLocaleDateString('pt-BR', { weekday: 'short', day: '2-digit' }));
            data.push(dailyTotals[dateStr] || 0);
        }

        // Atualizar gráfico
        const ctx = document.getElementById('productionChart');
        if (ctx) {
            if (window.productionChart) {
                window.productionChart.destroy();
            }

            window.productionChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Produção Diária (L)',
                        data: data,
                        borderColor: '#369e36',
                        backgroundColor: 'rgba(54, 158, 54, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0, 0, 0, 0.1)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });
        }

    } catch (error) {
        console.error('Erro ao carregar gráfico:', error);
    }
}

/**
 * Atualizar histórico de produção (CORRIGIDO)
 */
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

        // CORREÇÃO: Filtrar por farm_id em vez de user_id
        const { data: historyData, error } = await supabase
            .from('milk_production')
            .select(`
                id,
                volume_liters,
                production_date,
                shift,
                temperature,
                observations,
                created_at,
                users(name)
            `)
            .eq('farm_id', userData.farm_id)  // MUDANÇA: era user.id
            .order('production_date', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(50);

        if (error) throw error;

        const historyContainer = document.getElementById('historyContainer');
        if (!historyContainer) return;

        if (!historyData || historyData.length === 0) {
            historyContainer.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhum registro encontrado</p>';
            return;
        }

        historyContainer.innerHTML = historyData.map(record => {
            const date = new Date(record.production_date);
            const createdDate = new Date(record.created_at);
            const shiftText = {
                'manha': 'Manhã',
                'tarde': 'Tarde',
                'noite': 'Noite'
            }[record.shift] || record.shift;
            
            const userName = record.users?.name || 'Usuário';
            const isToday = record.production_date === formatLocalDate(new Date());
            
            return `
                <div class="data-card rounded-xl p-4 ${isToday ? 'ring-2 ring-green-500' : ''}">
                    <div class="flex items-center justify-between mb-2">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 gradient-forest rounded-lg flex items-center justify-center">
                                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-900">${record.volume_liters}L - ${shiftText}</h3>
                                <p class="text-sm text-gray-600">${date.toLocaleDateString('pt-BR')} • ${userName}</p>
                            </div>
                        </div>
                        <div class="text-right">
                            <div class="text-sm font-medium text-gray-900">${record.volume_liters}L</div>
                            <div class="text-xs text-gray-500">${createdDate.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</div>
                        </div>
                    </div>
                    ${record.temperature ? `
                        <div class="flex items-center space-x-2 text-sm text-gray-600 mb-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                            <span>Temperatura: ${record.temperature}°C</span>
                        </div>
                    ` : ''}
                    ${record.observations ? `
                        <div class="text-sm text-gray-600 bg-gray-50 rounded-lg p-2">
                            <strong>Observações:</strong> ${record.observations}
                        </div>
                    ` : ''}
                </div>
            `;
        }).join('');

    } catch (error) {
        console.error('Erro ao atualizar histórico:', error);
    }
}

// =====================================================
// FUNÇÕES AUXILIARES
// =====================================================

/**
 * Formatar data para formato local
 */
function formatLocalDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Calcular tempo decorrido
 */
function getTimeAgo(date) {
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);
    
    if (diffInSeconds < 60) return 'Agora mesmo';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m atrás`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h atrás`;
    return `${Math.floor(diffInSeconds / 86400)}d atrás`;
}

// =====================================================
// SUBSTITUIR FUNÇÕES ORIGINAIS
// =====================================================

// Substituir as funções originais pelas corrigidas
if (typeof loadDashboardIndicators === 'function') {
    window.loadDashboardIndicators = loadDashboardIndicators_FIXED;
}

if (typeof loadRecentActivity === 'function') {
    window.loadRecentActivity = loadRecentActivity_FIXED;
}

if (typeof loadProductionChart === 'function') {
    window.loadProductionChart = loadProductionChart_FIXED;
}

if (typeof refreshHistory === 'function') {
    window.refreshHistory = refreshHistory_FIXED;
}

// =====================================================
// INSTRUÇÕES DE USO
// =====================================================

/*
Para usar estas correções:

1. Inclua este arquivo no funcionario.html:
   <script src="fix_data_sync_complete.js"></script>

2. Ou substitua as funções originais pelas corrigidas

3. Teste o sistema para verificar se os dados aparecem corretamente

4. Verifique se tanto funcionários quanto gerentes veem os mesmos dados
*/

console.log('Correções de sincronização de dados carregadas!'); 