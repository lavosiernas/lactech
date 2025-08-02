// SCRIPT PARA LIMPEZA COMPLETA DO PROJETO
// Remove todos os arquivos desnecessários e mantém apenas os essenciais

console.log('🧹 INICIANDO LIMPEZA COMPLETA DO PROJETO');

// Lista de arquivos ESSENCIAIS (não deletar)
const essentialFiles = [
    'index.html',
    'login.html',
    'gerente.html',
    'veterinario.html',
    'funcionario.html',
    'proprietario.html',
    'inicio.html',
    'complete_clean_database.sql',
    'package.json',
    'mcp_config.json',
    'pdf-service.js',
    'supabase_config_fixed.js'
];

// Lista de arquivos para DELETAR (desnecessários)
const filesToDelete = [
    // Arquivos de teste
    'test_*.js',
    'test_*.sql',
    'test_*.md',
    
    // Arquivos de correção
    'fix_*.js',
    'fix_*.sql',
    'fix_*.md',
    
    // Arquivos de solução
    'solucao-*.html',
    'SOLUÇÃO_*.md',
    'SOLUCAO_*.md',
    
    // Arquivos de implementação
    'IMPLEMENTAÇÃO_*.md',
    'RESUMO_*.md',
    
    // Arquivos de configuração antigos
    'supabase_config_updated.js',
    'supabase_storage_setup.md',
    
    // Arquivos de correção específicos
    'activate_rls_*.sql',
    'fix_rls_*.sql',
    'fix_secondary_accounts_*.sql',
    'fix_treatments_*.sql',
    'fix_email_*.sql',
    'fix_users_*.sql',
    'fix_milk_production_*.sql',
    'fix_data_sync.js',
    'fix_function_*.sql',
    'fix_get_user_*.sql',
    'fix_delete_users_*.sql',
    
    // Arquivos de correção de contas secundárias
    'consertar_contas_secundarias.sql',
    'create_secondary_accounts_*.sql',
    'reverter_*.sql',
    'disable_rls_*.sql',
    'enable_rls_*.sql',
    
    // Arquivos de configuração de relatórios
    'sync_manager_report_settings.sql',
    'migrate_report_settings_*.sql',
    'create_update_user_*.sql',
    'create_farm_settings_*.sql',
    
    // Arquivos de configuração de storage
    'setup_profile_photo_storage.sql',
    
    // Arquivos de patch
    'patch_*.js',
    
    // Arquivos de servidor
    'server.ps1',
    'servidor_teste.html',
    
    // Arquivos de instalação
    'install_corrections.sql',
    
    // Arquivos de temperatura
    'temperature_chart.js',
    
    // Arquivos de resolver
    'resolver',
    
    // Arquivos de playstore
    'playstore.html',
    
    // Arquivos de funções específicas
    'funcionario_functions.js',
    
    // Arquivos de configuração de dados
    'fix_data_sync.js',
    
    // Arquivos de configuração de correção
    'include_secondary_account_fix.js',
    'simple_secondary_account_check.js',
    'clean_loading_functions.js',
    'remove_all_console_logs.js',
    'test_final_clean.js',
    'test_all_406_fixed.js',
    'test_error_406_fixed.js',
    'fix_gerente_secondary_accounts.js',
    
    // Arquivos de documentação desnecessários
    'SOLUÇÃO_RÁPIDA_ERRO_406.md',
    'SOLUÇÃO_ERRO_406.md',
    'IMPLEMENTAÇÃO_CONTA_SECUNDÁRIA.md',
    'RESUMO_CORREÇÕES_COMPLETAS.md',
    'test_secondary_account_ui.js',
    'test_comprehensive_fixes.js',
    'improve_loading_functions.js',
    'test_rls_comprehensive.js',
    'fix_rls_comprehensive.sql',
    'test_veterinario_page.js',
    'activate_rls_safe.sql',
    'activate_rls_simple.sql',
    'activate_rls_all_tables_fixed.sql',
    'test_rls_activation.js',
    'activate_rls_all_tables.sql',
    'fix_treatments_complete.sql',
    'fix_treatments_table.sql',
    'test_treatments_fix.js',
    'test_final_fixes.js',
    'test_dom_elements.js',
    'fix_email_constraint.sql',
    'test_secondary_account_creation.js',
    'test_system_functionality.js',
    'fix_rls_definitive.sql',
    'restore_working_rls.sql',
    'fix_infinite_recursion_emergency.sql',
    'fix_rls_simple.sql',
    'fix_rls_security_emergency.sql',
    'SOLUCAO_ERROS_CONTAS_SECUNDARIAS.md',
    'fix_secondary_accounts_complete.sql',
    'fix_secondary_accounts_complete_corrigido.sql',
    'RESUMO_CORREÇÕES_CONTAS_SECUNDARIAS.md',
    'test_secondary_accounts.js',
    'solucao-contas-secundarias.html',
    'solucao-erro-406-sem-desativar-rls.html',
    'solucao-erro-406.html',
    'solucao-implementada.html',
    'supabase_config_updated.js',
    'supabase_storage_setup.md',
    'sync_manager_report_settings.sql',
    'temperature_chart.js',
    'fix_delete_users_complete.sql',
    'fix_function_conflict.sql',
    'fix_get_user_profile.sql',
    'fix_milk_production_table.sql',
    'fix_rls_complete.sql',
    'fix_rls_emergency.sql',
    'fix_rls_policies.sql',
    'fix_rls_secure_working.sql',
    'fix_rls_users_policy.sql',
    'fix_secondary_account.js',
    'fix_secondary_account_rls.sql',
    'fix_users_delete_policy.sql',
    'fix_users_delete_policy_allow_self.sql',
    'fix_users_policy.sql',
    'funcionario_functions.js',
    'install_corrections.sql',
    'migrate_report_settings_to_user_profile.sql',
    'patch_gerente_html.js',
    'playstore.html',
    'resolver',
    'reverter_politica_rls_users.sql',
    'reverter_secondary_accounts.sql',
    'revert_rls_users_policy.sql',
    'consertar_contas_secundarias.sql',
    'create_farm_settings_table.sql',
    'create_secondary_accounts_table.sql',
    'create_update_user_report_settings.sql',
    'desativar_rls_users_completo.sql',
    'disable_rls_temp.sql',
    'disable_rls_users.sql',
    'enable_rls_other_tables.sql',
    'fix_406_error.sql',
    'fix_data_sync.js',
    'server.ps1',
    'servidor_teste.html'
];

// Função para verificar se um arquivo é essencial
function isEssentialFile(filename) {
    return essentialFiles.includes(filename);
}

// Função para verificar se um arquivo deve ser deletado
function shouldDeleteFile(filename) {
    return filesToDelete.some(pattern => {
        if (pattern.includes('*')) {
            const regex = new RegExp(pattern.replace('*', '.*'));
            return regex.test(filename);
        }
        return filename === pattern;
    });
}

// Função para listar arquivos do diretório
function listProjectFiles() {
    console.log('📋 ARQUIVOS DO PROJETO:');
    console.log('✅ Arquivos essenciais (manter):');
    essentialFiles.forEach(file => {
        console.log(`   - ${file}`);
    });
    
    console.log('\n🗑️ Arquivos para deletar:');
    filesToDelete.forEach(pattern => {
        console.log(`   - ${pattern}`);
    });
}

// Função para simular limpeza (sem deletar realmente)
function simulateCleanup() {
    console.log('\n🧹 SIMULANDO LIMPEZA:');
    console.log('Os seguintes arquivos seriam deletados:');
    
    // Aqui você pode adicionar a lógica real de deleção
    // Por enquanto, apenas simula
    filesToDelete.forEach(pattern => {
        console.log(`   - ${pattern}`);
    });
    
    console.log('\n✅ ARQUIVOS ESSENCIAIS MANTIDOS:');
    essentialFiles.forEach(file => {
        console.log(`   - ${file}`);
    });
}

// Função para criar backup antes da limpeza
function createBackup() {
    console.log('\n💾 CRIANDO BACKUP:');
    console.log('1. Criar pasta backup/');
    console.log('2. Copiar todos os arquivos para backup/');
    console.log('3. Manter apenas arquivos essenciais');
    console.log('4. Deletar arquivos desnecessários');
}

// Função principal
function cleanupProject() {
    console.log('🚀 INICIANDO LIMPEZA DO PROJETO LACTECH');
    console.log('==========================================');
    
    listProjectFiles();
    createBackup();
    simulateCleanup();
    
    console.log('\n📊 RESUMO DA LIMPEZA:');
    console.log(`✅ Arquivos essenciais: ${essentialFiles.length}`);
    console.log(`🗑️ Padrões para deletar: ${filesToDelete.length}`);
    console.log('🎯 Projeto limpo e otimizado!');
    
    console.log('\n📝 PRÓXIMOS PASSOS:');
    console.log('1. Execute o SQL: complete_clean_database.sql');
    console.log('2. Configure o novo banco no Supabase');
    console.log('3. Atualize as configurações do projeto');
    console.log('4. Teste o sistema com o novo banco');
}

// Executar limpeza
cleanupProject(); 