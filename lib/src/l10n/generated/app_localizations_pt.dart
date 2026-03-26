// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about => 'Sobre';

  @override
  String get addCategory => 'Adicionar Categoria';

  @override
  String get addToLibrary => 'Adicionar à biblioteca';

  @override
  String get advanced => 'Avançado';

  @override
  String get allScanlators => 'Todas as Scans';

  @override
  String get appLanguage => 'Idioma do aplicativo';

  @override
  String get appTheme => 'Tema do aplicativo';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Aparência';

  @override
  String get authType => 'Tipo de autenticação';

  @override
  String get authTypeBasic => 'Autenticação Básica';

  @override
  String get authTypeNone => 'Nenhum';

  @override
  String get authentication => 'Autenticação';

  @override
  String get autoDownload => 'Download automático';

  @override
  String get autoDownloadNewChapters => 'Baixe novos capítulos';

  @override
  String get automaticBackup => 'Backup automático';

  @override
  String get automaticUpdate => 'Atualização Automática';

  @override
  String get automaticallyRefreshMetadata =>
      'Recarregar automaticamente os metadados';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Buscar por novas capas e detalhes quando atualizar a biblioteca';

  @override
  String get backup => 'Backup e restauração';

  @override
  String get backupAndRestore => 'Fazer Backup e Restaurar';

  @override
  String get backupCleanup => 'Limpar Backups';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Delete Backups que são mais antigos que 1 dia',
        'other': 'Delete Backups que são mais antigos que $count dias',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'Intervalo de Backup';

  @override
  String get backupLocation => 'Local do backup';

  @override
  String get backupLocationDescription =>
      'O caminho para o diretório no servidor onde os backups automáticos devem ser salvos';

  @override
  String get backupTime => 'Hora do Backup';

  @override
  String get badges => 'Distintivos';

  @override
  String get bookmarked => 'Favoritado';

  @override
  String get browse => 'Navegar';

  @override
  String get buildTime => 'Tempo de compilação';

  @override
  String get cacheCleared => 'Cache limpo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get categories => 'Categorias';

  @override
  String get categoryUpdate => 'Atualização de categoria';

  @override
  String get channel => 'Canal';

  @override
  String get chapterDownloadLimit => 'Limite de download de capítulos';

  @override
  String get chapterDownloadLimitDesc =>
      'Limite a quantidade de capítulos novos que serão baixados.';

  @override
  String chapterNumber(double number) {
    return 'Capítulo $number';
  }

  @override
  String get chapterSortFetchedDate => 'Por Data de Busca';

  @override
  String get chapterSortSource => 'Por fonte';

  @override
  String get chapterSortUploadDate => 'Por Data de Envio';

  @override
  String get checkForServerUpdates => 'Procurar atualizações do servidor';

  @override
  String get checkForUpdates => 'Procurar atualizações';

  @override
  String get clearCache => 'Limpar Cache';

  @override
  String get client => 'Cliente';

  @override
  String get clientVersion => 'Versão do Cliente';

  @override
  String get close => 'Fechar';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Completo';

  @override
  String get copied => 'Copiado!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Copiado para área de transferência!';
  }

  @override
  String get createBackupDescription =>
      'Salvar a biblioteca como um backup do Tachidesk';

  @override
  String get createBackupTitle => 'Criar Backup';

  @override
  String get credentials => 'Credenciais';

  @override
  String get current => 'Atuais';

  @override
  String daysAgo(Object days) {
    return '$days dias atrás';
  }

  @override
  String get debugLogs => 'Registros de debug';

  @override
  String get defaultCategory =>
      'Categoria predefinida quando um novo mangá é adicionado à biblioteca';

  @override
  String get delete => 'Remover';

  @override
  String get deleteCategoryDescription =>
      'Isto mesclará todos os mangás desta categoria para predefinidos!';

  @override
  String get deleteCategoryTitle => 'Tem certeza?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Exibição';

  @override
  String get displayMode => 'Modo de exibição';

  @override
  String get displayModeDescriptiveList => 'Lista descritiva';

  @override
  String get displayModeGrid => 'Grade';

  @override
  String get displayModeList => 'Lista';

  @override
  String get downloadLocation => 'Local de download';

  @override
  String get downloadLocationHint =>
      'O caminho para o diretório no servidor onde os arquivos baixados devem ser salvos';

  @override
  String get downloaded => 'Transferidos';

  @override
  String get downloading => 'Baixando';

  @override
  String get downloads => 'Baixados';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar Categoria';

  @override
  String get emptyCategory => 'Nome da categoria não pode ficar em branco';

  @override
  String get enableSocksProxy => 'Use Proxy SOCKS';

  @override
  String enterProp(Object prop) {
    return 'Entrar $prop';
  }

  @override
  String get error => 'Erro';

  @override
  String get errorBackupCreate => 'Falha ao criar Backup';

  @override
  String get errorBackupRestore => 'Falha ao restaurar Backup!';

  @override
  String get errorExtension =>
      'Não foi possível encontrar a extensão selecionada';

  @override
  String get errorFilePick => 'Arquivo não selecionado!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Por favor selecione um arquivo com $extensionName extensão';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Falha ao abrir!\nCopiando \"$url\" para a área de transferência';
  }

  @override
  String get errorPassword => 'Senha não pode ficar em branco';

  @override
  String get errorSomethingWentWrong => 'Algo correu mal!';

  @override
  String get errorUserName => 'Nome de usuário não pode ficar em branco';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignorar downloads automáticos de capítulos para entradas com capítulos não lidos';

  @override
  String get extensionInstalled => 'Extensão instalada!';

  @override
  String get extensionListEmpty => 'Lista de extensão está vazia';

  @override
  String get extensionRepository => 'Repositório de extensões';

  @override
  String get extensionRepositoryDescription =>
      'Adicione repositórios de onde as extensões podem ser instaladas';

  @override
  String get extensions => 'Extensões';

  @override
  String get failed => 'Falha';

  @override
  String get filter => 'Filtro';

  @override
  String get findServer => 'Procurar';

  @override
  String get finished => 'Concluído';

  @override
  String get flareSolverr => 'FlareSolverr';

  @override
  String get flareSolverrRequestTimeout =>
      'Tempo limite da solicitação do FlareSolverr';

  @override
  String get flareSolverrServerUrl => 'URL do servidor FlareSolverr';

  @override
  String get flareSolverrSessionName => 'Nome da sessão do FlareSolverr';

  @override
  String get flareSolverrSessionTTL => 'TTL da sessão do FlareSolverr';

  @override
  String get general => 'Geral';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Procura global';

  @override
  String get globalUpdate => 'Atualização global';

  @override
  String get gqlDebugLogs => 'Logs de depuração do Graphql';

  @override
  String get gqlDebugLogsHint =>
      'Isso inclui registros com informações não seguras de privacidade';

  @override
  String get help => 'Ajuda';

  @override
  String get hideEmptyCategory => 'Ocultar categoria vazia';

  @override
  String get inLibrary => 'Na Biblioteca';

  @override
  String get includeCategories => 'Categorias';

  @override
  String get includeChapters => 'Capítulos';

  @override
  String get install => 'Instalar';

  @override
  String get installing => 'A Instalar';

  @override
  String get installingExtension => 'Instalando extensão';

  @override
  String get invalidPort => 'Porta inválida';

  @override
  String invalidProp(Object property) {
    return 'inválida $property';
  }

  @override
  String get ip => 'Endereço IP';

  @override
  String get ipHintText => 'Insira o endereço IP de vinculação do servidor';

  @override
  String get isTrueBlack => 'Preto puro';

  @override
  String get languages => 'Idiomas';

  @override
  String get latest => 'Mais recente';

  @override
  String get library => 'Biblioteca';

  @override
  String get localSourceLocation => 'Localização da fonte local';

  @override
  String get localSourceLocationDescription =>
      'O caminho para o diretório no servidor onde os arquivos de origem locais são salvos';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Tamanho da tela do mangá';

  @override
  String get mangaMissingSources => 'Fontes do manga em falta';

  @override
  String get mangaSortAlphabetical => 'Ordem alfabética';

  @override
  String get mangaSortDateAdded => 'Data adicionada';

  @override
  String get mangaSortLastRead => 'Última leitura';

  @override
  String get mangaSortLastUpdated => 'Última atualização';

  @override
  String get mangaSortUnread => 'Não lido';

  @override
  String get mangaStatusCancelled => 'Cancelado';

  @override
  String get mangaStatusCompleted => 'Completo';

  @override
  String get mangaStatusLicensed => 'Licenciado';

  @override
  String get mangaStatusOnHiatus => 'Em curso';

  @override
  String get mangaStatusOngoing => 'Em pausa';

  @override
  String get mangaStatusPublishingFinished => 'Publicação concluída';

  @override
  String get mangaStatusUnknown => 'Desconhecido';

  @override
  String get misc => 'Diversos';

  @override
  String get missingExtension => 'Extensões em falta';

  @override
  String get missingTrackers => 'Rasteadores em falta';

  @override
  String get more => 'Mais';

  @override
  String get moveToBottom => 'Mover para baixo';

  @override
  String get moveToTop => 'Mover para cima';

  @override
  String nChapters(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Chapters',
      one: '1 Chapter',
      zero: 'None',
    );
    return '$_temp0';
  }

  @override
  String nDays(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '01': '01 Day',
        'other': '$count Days',
      },
    );
    return '$_temp0';
  }

  @override
  String nHours(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Minutes',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String nRepo(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Repos',
      one: '1 Repo',
    );
    return '$_temp0';
  }

  @override
  String nSeconds(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String nSources(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sources',
      one: '1 Source',
    );
    return '$_temp0';
  }

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => 'Nova atualização disponível';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Próximo: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Não tem nenhuma categoria.\nToque no botão mais para criar uma categoria para organizar a sua biblioteca';

  @override
  String get noCategoriesFoundAlt =>
      'Não tem nenhuma categoria.\nCria uma nas definições para organizar a sua biblioteca';

  @override
  String get noCategoryMangaFound =>
      'Nenhum manga encontrado nesta categoria.\n(Dica: Verifique as suas pesquisas e filtros!)';

  @override
  String get noChaptersFound => 'Nenhum capítulo encontrado';

  @override
  String get noDownloads => 'Nenhuma transferência';

  @override
  String get noMangaFound => 'Nenhum manga encontrado';

  @override
  String noOfChapters(int count) {
    return '$count Capítulos';
  }

  @override
  String noPropFound(Object prop) {
    return 'Nenhum $prop encontrado';
  }

  @override
  String get noResultFound => 'Nenhum resultado encontrado';

  @override
  String get noServerFound => 'Servidor não encontrado em sua rede local';

  @override
  String get noSourcesFound => 'Nenhuma fonte encontrada';

  @override
  String get noUpdatesAvailable => 'Está a usar a versão mais recente';

  @override
  String get noUpdatesFound => 'Nenhuma atualização encontrada';

  @override
  String get none => 'Nenhum';

  @override
  String get nsfw => 'Mostrar extensões e fontes NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Isto não impede extensões não oficiais ou incorretamente marcadas de mostrarem conteúdo NSFW (18+) dentro da aplicação';

  @override
  String numSelected(int num) {
    return '$num Selecionado';
  }

  @override
  String get obsolete => 'Obsoleta';

  @override
  String get openFlareSolverr =>
      'Consulte o FlareSolverr para obter informações sobre como configurá-lo';

  @override
  String get openInWeb => 'Abrir na Web';

  @override
  String get or => 'ou';

  @override
  String page(int number) {
    return 'Página: $number';
  }

  @override
  String get parallelSourceRequest => 'Solicitações de fontes paralelas';

  @override
  String get password => 'Senha';

  @override
  String get pause => 'Pausa';

  @override
  String get pending => 'Pendente';

  @override
  String get pinchToZoom => 'Aperte para ampliar';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Anterior: $chapterTitle';
  }

  @override
  String get queued => 'Na fila';

  @override
  String get quickSearch => 'Pesquisa rápida';

  @override
  String get quickSearchCategory => 'Vá para categoria \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Pesquisa o Manga \'M\' na categoria \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Pesquisa o capítulo \'CN\' na manga \'M\' na Categoria \'C\'';

  @override
  String get quickSearchContext =>
      'Pesquisa padrão (Resultado baseado nas informações da tela)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Dica: clique em \'?\' para ver todos os comandos';

  @override
  String get quickSearchSource => 'Pesquisa a fonte \'S\'';

  @override
  String get quickSearchSourceManga => 'Pesquisa o mangá \'M\' na fonte \'S\'';

  @override
  String get reader => 'Leitor';

  @override
  String get readerMagnifierSize => 'Tamanho da Lupa';

  @override
  String get readerMode => 'Modo de leitura';

  @override
  String get readerModeContinuousHorizontalLTR => 'Horizontal Contínuo (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Horizontal Contínuo (RTL)';

  @override
  String get readerModeContinuousVertical => 'Vertical Contínuo';

  @override
  String get readerModeDefaultReader => 'Predefinido';

  @override
  String get readerModeSingleHorizontalLTR => 'Horizontal único (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Horizontal único (RTL)';

  @override
  String get readerModeSingleVertical => 'Vertical único';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Disposição de Navegação';

  @override
  String get readerNavigationLayoutDefault => 'Predefinido';

  @override
  String get readerNavigationLayoutDisabled => 'Desativado';

  @override
  String get readerNavigationLayoutEdge => 'Borda';

  @override
  String get readerNavigationLayoutInvert => 'Inverter toque';

  @override
  String get readerNavigationLayoutKindlish => 'Formato Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'Formato L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Direita para Esquerda';

  @override
  String get readerOverlay => 'Sobreposição inicial do leitor';

  @override
  String get readerOverlaySubtitle =>
      'Mostra título e configurações rápidas ao abrir um capítulo';

  @override
  String get readerPadding => 'Preenchimento do leitor';

  @override
  String get readerScrollAnimation => 'Animação de rolagem';

  @override
  String get readerSwipeChapterToggle => 'Deslize para alternar';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Deslize para mudar o capítulo no leitor';

  @override
  String get readerLastPageSwipeToggle => 'Gesto na última página';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Deslizar para o próximo capítulo só na última página';

  @override
  String get readerVolumeTap => 'Botões de volume';

  @override
  String get readerVolumeTapInvert => 'inverter botões de volume';

  @override
  String get readerVolumeTapSubtitle => 'Navegue com botões de volume';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignorar área segura';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Recarregar';

  @override
  String get migrate => 'Migrar';

  @override
  String get migrationSelectTargetSource => 'Selecione a fonte de destino';

  @override
  String migrationSearchInSource(Object sourceName) {
    return 'Pesquisar em $sourceName';
  }

  @override
  String get migrationPreview => 'Pré-visualizar migração';

  @override
  String get migrationInProgress => 'Migração em Progresso';

  @override
  String get migrationComplete => 'Migração concluída com sucesso';

  @override
  String get migrationFailed => 'Migração Falhou';

  @override
  String get migrationCancelled => 'Migração cancelada';

  @override
  String get migrateChapters => 'Migrar capítulos';

  @override
  String get migrateChaptersDescription =>
      'Copie o status do capítulo lido para nova fonte';

  @override
  String get migrateCategories => 'Migrar categorias';

  @override
  String get migrateCategoriesDescription =>
      'Copiar categorias do mangá para nova fonte';

  @override
  String get migrateDownloads => 'Migrar Downloads';

  @override
  String get migrateDownloadsDescription =>
      'Mover capítulos baixados para nova fonte';

  @override
  String get migrateTracking => 'Migrar Rastreadores';

  @override
  String get migrateTrackingDescription =>
      'Copiar informações de rastreamento para nova fonte';

  @override
  String get migrationOptions => 'Opções de migração';

  @override
  String get migrationSettings => 'Configurações de migração';

  @override
  String get selectTargetSource => 'Selecione a fonte de destino';

  @override
  String get noSourcesAvailable =>
      'Não existem fontes disponíveis para migração';

  @override
  String get checkSourceConfiguration =>
      'Por favor, verifique a configuração da sua fonte';

  @override
  String get noAlternativeSources =>
      'Não existem fontes alternativas disponíveis';

  @override
  String get installMoreSources =>
      'Instale mais fontes para habilitar a migração';

  @override
  String get errorLoadingSources => 'Erro ao carregar fontes';

  @override
  String get errorGettingMigrationSources =>
      'Falha ao obter fontes de migração';

  @override
  String get errorSearchingMangaInSource => 'Falha ao procurar mangá na fonte';

  @override
  String get errorFetchingSourceManga => 'Falha ao buscar mangá de origem';

  @override
  String get errorSourceMangaNotFound => 'Mangá de origem não encontrado';

  @override
  String get errorFetchingTargetManga => 'Falha ao buscar mangá destino';

  @override
  String get errorTargetMangaNotFound => 'Mangá alvo não encontrado';

  @override
  String get searchManga => 'Procurar mangá...';

  @override
  String get searchForManga => 'Procurar mangá na fonte destino';

  @override
  String get enterSearchTerm =>
      'Digite um termo de pesquisa para encontrar mangá';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get tryDifferentSearch => 'Experimente um termo de pesquisa diferente';

  @override
  String get searchError => 'Erro de pesquisa';

  @override
  String get importantNotice => 'Aviso Importante';

  @override
  String get migrationWarning =>
      'Isso irá mover permanentemente seus dados de mangá. Esta ação não pode ser desfeita.';

  @override
  String get deleteSourceWarning =>
      'O mangá original será removido de sua biblioteca após a migração.';

  @override
  String get confirmMigration => 'Confirme a migração';

  @override
  String get migrationConfirmationMessage =>
      'Tem certeza de que quer migrar este mangá? Esta ação não pode ser desfeita.';

  @override
  String get startMigration => 'Iniciar migração';

  @override
  String get preparingMigration => 'Preparando a migração...';

  @override
  String get migrationCompleted => 'Migração concluída!';

  @override
  String get migrationSuccessMessage =>
      'Seu mangá foi migrado com sucesso para a nova fonte.';

  @override
  String get migrationCancelledMessage =>
      'O processo de migração foi cancelado. Não foram feitas alterações.';

  @override
  String get cancelMigration => 'Cancelar migração';

  @override
  String get cancelMigrationConfirmation =>
      'Tem certeza de que quer cancelar a migração? Esta ação não pode ser desfeita.';

  @override
  String get quickPresets => 'Presets rápidos';

  @override
  String get quickMigration => 'Rápido';

  @override
  String get fullMigration => 'Total';

  @override
  String get customMigration => 'Personalizado';

  @override
  String get deleteSourceManga => 'Deletar mangá fonte';

  @override
  String get deleteSourceMangaDescription =>
      'Remova o mangá original da biblioteca após a migração';

  @override
  String get done => 'Feito';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get from => 'A partir de';

  @override
  String get to => 'Para';

  @override
  String get source => 'Fonte';

  @override
  String get migrationDetails => 'Detalhes da migração';

  @override
  String get searchAllSources => 'Pesquisar todas as fontes';

  @override
  String get searchingAllSources =>
      'Procurando em todas as fontes disponíveis...';

  @override
  String get noMatchingMangaFound =>
      'Nenhum mangá correspondente encontrado em qualquer fonte';

  @override
  String get deleteSourceAfterMigration =>
      'Excluir mangá origem após a migração';

  @override
  String get reload => 'Recarregar';

  @override
  String get remove => 'Remover';

  @override
  String get removeFromLibrary => 'Remover da Biblioteca?';

  @override
  String get reset => 'Reiniciar';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreBackupDescription =>
      'Restaurar Tachidesk pela cópia de segurança';

  @override
  String get restoreBackupTitle => 'Restaurar cópia de segurança';

  @override
  String get restored => 'Cópia de segurança restaurada!';

  @override
  String get restoring => 'Restaurando backup';

  @override
  String get resume => 'Continuar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get running => 'Em execução';

  @override
  String get save => 'Guardar';

  @override
  String get saveAsCBZArchive => 'Salvar como arquivo CBZ';

  @override
  String get scanlators => 'Scans';

  @override
  String get search => 'Procurar';

  @override
  String get searchingForUpdates => 'Procurando por atualizações';

  @override
  String get selectInBetween => 'Selecione entre';

  @override
  String get selectNext10 => 'Selecione os próximos 10';

  @override
  String get selectUnread => 'Selecione os não lidos';

  @override
  String get server => 'Servidor';

  @override
  String get serverBindings => 'Ligações do servidor';

  @override
  String get serverPort => 'Porta do servidor';

  @override
  String get serverPortHintText => 'Porta do servidor';

  @override
  String get serverUrl => 'URL do Server';

  @override
  String get serverUrlHintText => 'URL do servidor';

  @override
  String get serverVersion => 'Versão do servidor';

  @override
  String get settings => 'Definições';

  @override
  String get skipUpdatingEntries => 'Pular atualização de entradas';

  @override
  String get socksHost => 'Host SOCKS';

  @override
  String get socksPassword => 'Senha SOCKS';

  @override
  String get socksPort => 'Porta SOCKS';

  @override
  String get socksProxy => 'Proxy SOCKS';

  @override
  String get socksUserName => 'Nome de usuário SOCKS';

  @override
  String get socksVersion => 'Versão SOCKS';

  @override
  String get sort => 'Ordenar';

  @override
  String get sourceTypeFilter => 'Filtro';

  @override
  String get sourceTypeLatest => 'Mais recentes';

  @override
  String get sourceTypePopular => 'Popular';

  @override
  String get sources => 'Fontes';

  @override
  String get start => 'Inicio';

  @override
  String get systemTrayIcon => 'Mostrar ícone na bandeja do sistema';

  @override
  String get thatHaventBeenStarted => 'Que ainda não foram iniciadas';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get today => 'Hoje';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String get uninstalling => 'A Desinstalar';

  @override
  String get unknownAuthor => 'Autor Desconhecido';

  @override
  String get unknownManga => 'Manga Desconhecido';

  @override
  String get unknownSource => 'Fonte Desconhecida';

  @override
  String get unread => 'Não lida';

  @override
  String get update => 'Atualização';

  @override
  String get updateCompleted => 'Atualização Completa';

  @override
  String updateFailed(Object property) {
    return 'Falha ao atualizar $property';
  }

  @override
  String get updates => 'Atualizações';

  @override
  String get updatesSummary => 'Resumo de Atualizações';

  @override
  String get updating => 'Atualizando';

  @override
  String get userName => 'Nome de Utilizador';

  @override
  String get validating => 'Validando';

  @override
  String versionAvailable(String app, String version) {
    return 'Versão $version disponivel para $app!!';
  }

  @override
  String get webUI => 'Abrir no WEB';

  @override
  String get webView => 'WebView';

  @override
  String get whatsNew => 'O que há de Novo?';

  @override
  String get withCompletedStatus => 'Com status Concluído';

  @override
  String get withUnreadChapter => 'Com capítulo(s) não lido(s)';

  @override
  String get yesterday => 'Ontem';

  @override
  String get recentlyRead => 'Lidos recentemente';

  @override
  String get history => 'Histórico';

  @override
  String get searchHistory => 'Pesquisar histórico...';

  @override
  String get noHistoryFound => 'Nenhum histórico de leitura encontrado';

  @override
  String get startReadingToSeeHistory =>
      'Comece a ler mangás para ver seu histórico aqui';

  @override
  String get noSearchResults => 'Sem resultados de pesquisa';

  @override
  String get tryDifferentSearchTerm =>
      'Experimente um termo de pesquisa diferente';

  @override
  String get errorOccurred => 'Um erro ocorreu';

  @override
  String get viewManga => 'Ver Mangá';

  @override
  String get removeFromHistory => 'Remover do Histórico';

  @override
  String get removeFromHistoryConfirmation =>
      'Tem certeza de que deseja remover este capítulo do seu histórico de leitura?';

  @override
  String get timeoutSettings => 'Configurações de timeout';

  @override
  String get serverRequestTimeout => 'Server Request Timeout';

  @override
  String get serverRequestTimeoutDescription =>
      'Tempo para esperar por respostas do servidor (em segundos)';

  @override
  String get autoRefreshOnTimeout => 'Auto-refresh no Timeout';

  @override
  String get autoRefreshOnTimeoutDescription =>
      'Automatically retries requests that timeout';

  @override
  String get autoRefreshRetryDelay => 'Auto-refresh Retry Delay';

  @override
  String get autoRefreshRetryDelayDescription =>
      'Delay between auto retry attempts (in seconds)';

  @override
  String get trackers => 'Trackers';

  @override
  String get tracking => 'Tracking';

  @override
  String get addTracking => 'Add Tracking';

  @override
  String get trackingSearch => 'Search on tracker...';

  @override
  String get trackingStatus => 'Status';

  @override
  String get trackingScore => 'Score';

  @override
  String get trackingLastChapter => 'Last Chapter Read';

  @override
  String get trackingStartDate => 'Start Date';

  @override
  String get trackingFinishDate => 'Finish Date';

  @override
  String get trackingRemoveConfirm => 'Remove tracking?';

  @override
  String get trackingRemoveDescription =>
      'This will remove the tracking entry from Catalyst. The entry on the tracker service will not be deleted.';

  @override
  String get trackingRemoveAlsoRemote => 'Also delete from tracker service';

  @override
  String get logIn => 'Log In';

  @override
  String get logOut => 'Log Out';

  @override
  String get loggedIn => 'Logged in';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get noTrackingFound => 'No tracking entries yet';

  @override
  String get trackerNoResults => 'No results found on tracker';

  @override
  String get syncNow => 'Sync now';

  @override
  String get mangaComparison => 'Manga Comparison';

  @override
  String get migrationFromLabel => 'From (Current)';

  @override
  String get migrationToLabel => 'To (Target)';

  @override
  String get comparisonSummary => 'Comparison Summary';

  @override
  String byAuthor(String author) {
    return 'by $author';
  }

  @override
  String get migrationSummaryTitle => 'Migration Summary';

  @override
  String migratedFromManga(String title) {
    return 'Migrated from: $title';
  }

  @override
  String migratedToManga(String title) {
    return 'Migrated to: $title';
  }

  @override
  String migrationSourceLabel(String name) {
    return 'Source: $name';
  }

  @override
  String get selectSource => 'Select Source';

  @override
  String get selectManga => 'Select Manga';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get about => 'Sobre';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get about => 'Sobre';

  @override
  String get addCategory => 'Adicionar Categoria';

  @override
  String get addToLibrary => 'Adicionar à biblioteca';

  @override
  String get allScanlators => 'Todas Scans';

  @override
  String get appLanguage => 'Idioma da aplicação';

  @override
  String get appTheme => 'Tema da Aplicação';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Aparência';

  @override
  String get authType => 'Tipo de autenticação';

  @override
  String get authTypeBasic => 'Autenticação Básica';

  @override
  String get authTypeNone => 'Nenhum';

  @override
  String get backup => 'Cópia de segurança e restaurar';

  @override
  String get badges => 'Distintivos';

  @override
  String get bookmarked => 'Marcado';

  @override
  String get browse => 'Procurar';

  @override
  String get buildTime => 'Tempo de compilação';

  @override
  String get cacheCleared => 'Cache limpo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get categories => 'Categorias';

  @override
  String get categoryUpdate => 'Atualização de categoria';

  @override
  String get channel => 'Canal';

  @override
  String chapterNumber(double number) {
    return 'Capítulo $number';
  }

  @override
  String get chapterSortFetchedDate => 'Recolhidos por data';

  @override
  String get chapterSortSource => 'Por fonte';

  @override
  String get chapterSortUploadDate => 'Por Data de Upload';

  @override
  String get checkForServerUpdates => 'Procurar atualizações do servidor';

  @override
  String get checkForUpdates => 'Procurar atualizações';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Versão Client';

  @override
  String get close => 'Fechar';

  @override
  String get completed => 'Completo';

  @override
  String copyMsg(String msg) {
    return '\"$msg\" Copiado!';
  }

  @override
  String get createBackupDescription =>
      'Cópia da Biblioteca como cópia de segurança de Tachidesk';

  @override
  String get createBackupTitle => 'Criar cópia de segurança';

  @override
  String get credentials => 'Credenciais';

  @override
  String get current => 'Atuais';

  @override
  String daysAgo(Object days) {
    return '$days dias atrás';
  }

  @override
  String get defaultCategory =>
      'Categoria predefinida quando um novo mangá é adicionado à biblioteca';

  @override
  String get delete => 'Remover';

  @override
  String get deleteCategoryDescription =>
      'Isto irá fundir todos os mangas desta categoria para predefinidos!';

  @override
  String get deleteCategoryTitle => 'Tem a certeza?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Exibir';

  @override
  String get displayMode => 'Modo de exibição';

  @override
  String get displayModeDescriptiveList => 'Lista descritiva';

  @override
  String get displayModeGrid => 'Grelha';

  @override
  String get displayModeList => 'Lista';

  @override
  String get downloaded => 'Transferidos';

  @override
  String get downloads => 'Transferências';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar Categoria';

  @override
  String get emptyCategory => 'Nome da categoria não pode ficar em branco';

  @override
  String get errorExtension =>
      'Não foi possível encontrar a extensão selecionada';

  @override
  String get errorFilePick => 'Arquivo não selecionado!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Por favor selecione um arquivo com $extensionName extensão';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Falha ao abrir!\nA Copiar \"$url\" para a área de transferência';
  }

  @override
  String get errorPassword => 'Senha não pode ficar em branco';

  @override
  String get errorSomethingWentWrong => 'Algo correu mal!';

  @override
  String get errorUserName => 'Nome de utilizador não pode ficar em branco';

  @override
  String get extensionInstalled => 'Extensão instalada!';

  @override
  String get extensionListEmpty => 'Lista de extensão está vazia';

  @override
  String get extensions => 'Extensões';

  @override
  String get failed => 'Falha';

  @override
  String get filter => 'Filtro';

  @override
  String get findServer => 'Procurar';

  @override
  String get finished => 'Concluído';

  @override
  String get general => 'Geral';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Procura global';

  @override
  String get globalUpdate => 'Atualização global';

  @override
  String get help => 'Ajuda';

  @override
  String get inLibrary => 'Na Biblioteca';

  @override
  String get install => 'Instalar';

  @override
  String get installing => 'A Instalar';

  @override
  String get installingExtension => 'A instalar extensões';

  @override
  String get languages => 'Idiomas';

  @override
  String get latest => 'Mais recente';

  @override
  String get library => 'Biblioteca';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Tamanho do Manga na Grelha';

  @override
  String get mangaMissingSources => 'Fontes do manga em falta';

  @override
  String get mangaSortAlphabetical => 'Ordem alfabética';

  @override
  String get mangaSortDateAdded => 'Data adicionada';

  @override
  String get mangaSortLastRead => 'Última leitura';

  @override
  String get mangaSortUnread => 'Não lido';

  @override
  String get mangaStatusCancelled => 'Cancelado';

  @override
  String get mangaStatusCompleted => 'Completo';

  @override
  String get mangaStatusLicensed => 'Licenciado';

  @override
  String get mangaStatusOnHiatus => 'Em curso';

  @override
  String get mangaStatusOngoing => 'Em pausa';

  @override
  String get mangaStatusPublishingFinished => 'Publicação concluída';

  @override
  String get mangaStatusUnknown => 'Desconhecido';

  @override
  String get missingExtension => 'Extensões em falta';

  @override
  String get missingTrackers => 'Rasteadores em falta';

  @override
  String get more => 'Mais';

  @override
  String get moveToBottom => 'Mover para baixo';

  @override
  String get moveToTop => 'Mover para cima';

  @override
  String nameCountDisplay(int count, String name) {
    return '$name: $count';
  }

  @override
  String get newUpdateAvailable => 'Nova atualização disponível';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Próximo: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'Não tem nenhuma categoria.\n(Dica: Toque no botão mais para criar uma categoria para organizar a sua biblioteca)';

  @override
  String get noCategoriesFoundAlt =>
      'Não tem nenhuma categoria.\nCria uma nas definições para organizar a sua biblioteca';

  @override
  String get noCategoryMangaFound =>
      'Nenhum manga encontrado nesta categoria.\n(Dica: Verifique as suas pesquisas e filtros!)';

  @override
  String get noChaptersFound => 'Nenhum capítulo encontrado';

  @override
  String get noDownloads => 'Nenhuma transferência';

  @override
  String get noMangaFound => 'Nenhum manga encontrado';

  @override
  String noOfChapters(int count) {
    return '$count Capítulos';
  }

  @override
  String get noResultFound => 'Nenhum resultado encontrado';

  @override
  String get noServerFound =>
      'Nenhum servidor encontrado em sua rede local, adicione manualmente';

  @override
  String get noSourcesFound => 'Nenhuma fonte encontrada';

  @override
  String get noUpdatesAvailable => 'Está a usar a versão mais recente';

  @override
  String get noUpdatesFound => 'Nenhuma atualização encontrada';

  @override
  String get nsfw => 'Mostrar extensões e fontes NSFW';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'Isto não impede extensões não oficiais ou incorretamente marcadas de mostrarem conteúdo NSFW (18+) dentro da aplicação';

  @override
  String numSelected(int num) {
    return '$num Selecionado';
  }

  @override
  String get obsolete => 'Obsoleta';

  @override
  String page(int number) {
    return 'Página: $number';
  }

  @override
  String get password => 'Senha';

  @override
  String get pause => 'Pausa';

  @override
  String get pending => 'Pendente';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Anterior: $chapterTitle';
  }

  @override
  String get quickSearchCategory => 'Ir para a Categoria \'C\'';

  @override
  String get quickSearchCategoryManga =>
      'Ir para o Manga \'M\' na Categoria \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Ir para o Nome do Capitulo \'CN\' Do Manga \'M\' na Categoria \'C\'';

  @override
  String get quickSearchContext => '';

  @override
  String get quickSearchShowAllCommandTip =>
      'Dica: Digite \"?\" Para ver todos os comandos';

  @override
  String get quickSearchSource => 'Ir para a Fonte \'S\'';

  @override
  String get quickSearchSourceManga =>
      'Procurar por manga \'M\' na Fonte \'S\'';

  @override
  String get reader => 'Leitor';

  @override
  String get readerMagnifierSize => 'Tamanho da lupa';

  @override
  String get readerMode => 'Modo de leitura';

  @override
  String get readerModeContinuousHorizontalLTR => 'Horizontal Contínuo (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Horizontal Contínuo (RTL)';

  @override
  String get readerModeContinuousVertical => 'Vertical Contínuo';

  @override
  String get readerModeDefaultReader => 'Predefinido';

  @override
  String get readerModeSingleHorizontalLTR => 'Horizontal único (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Horizontal único (RTL)';

  @override
  String get readerModeSingleVertical => 'Vertical único';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Disposição de Navegação';

  @override
  String get readerNavigationLayoutDefault => 'Predefinido';

  @override
  String get readerNavigationLayoutDisabled => 'Desativado';

  @override
  String get readerNavigationLayoutEdge => 'Borda';

  @override
  String get readerNavigationLayoutInvert => 'Inverter toque';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'Formato L';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Direita para Esquerda';

  @override
  String get readerOverlay => 'Overlay inicial do Leitor';

  @override
  String get readerOverlaySubtitle =>
      'Mostrar título e definições rápidas ao abrir o capítulo';

  @override
  String get readerPadding => 'Preenchimento do Leitor';

  @override
  String get readerScrollAnimation => 'Animação do Scroll';

  @override
  String get readerSwipeChapterToggle => 'Alternar deslize';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Deslizar para mudar Capitulo no leitor';

  @override
  String get readerVolumeTap => 'Teclas de volume';

  @override
  String get readerVolumeTapInvert => 'Inverter teclas de volume';

  @override
  String get readerVolumeTapSubtitle => 'Navegar com teclas de volume';

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Recarregar';

  @override
  String get source => 'Fonte';

  @override
  String get reload => 'recarregar';

  @override
  String get remove => 'Remover';

  @override
  String get removeFromLibrary => 'Remover da Biblioteca?';

  @override
  String get reset => 'Reiniciar';

  @override
  String get restoreBackupDescription =>
      'Restaurar Tachidesk pela cópia de segurança';

  @override
  String get restoreBackupTitle => 'Restaurar cópia de segurança';

  @override
  String get restored => 'Cópia de segurança restaurada!';

  @override
  String get restoring => 'A restaurar cópia de segurança';

  @override
  String get resume => 'Continuar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get running => 'Em execução';

  @override
  String get save => 'Guardar';

  @override
  String get scanlators => 'Scanlators';

  @override
  String get search => 'Procurar';

  @override
  String get searchingForUpdates => 'À procura de atualizações';

  @override
  String get selectInBetween => 'Selecionar no Meio';

  @override
  String get selectNext10 => 'Selecionar os Proximos 10';

  @override
  String get selectUnread => 'Selecionar os não lidos';

  @override
  String get server => 'Servidor';

  @override
  String get serverPort => 'Porta do Servidor';

  @override
  String get serverPortHintText => 'Porta do Servidor';

  @override
  String get serverUrl => 'URL do Server';

  @override
  String get serverUrlHintText => 'Url do server';

  @override
  String get serverVersion => 'Versão do servidor';

  @override
  String get settings => 'Definições';

  @override
  String get sort => 'Ordenar';

  @override
  String get sourceTypeFilter => 'Filtro';

  @override
  String get sourceTypeLatest => 'Mais recentes';

  @override
  String get sourceTypePopular => 'Popular';

  @override
  String get sources => 'Fontes';

  @override
  String get start => 'Inicio';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get today => 'Hoje';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String get uninstalling => 'A Desinstalar';

  @override
  String get unknownAuthor => 'Autor Desconhecido';

  @override
  String get unknownManga => 'Manga Desconhecido';

  @override
  String get unknownSource => 'Fonte Desconhecida';

  @override
  String get unread => 'Não lida';

  @override
  String get update => 'Atualização';

  @override
  String get updateCompleted => 'Atualização Completa';

  @override
  String get updates => 'Atualizações';

  @override
  String get updatesSummary => 'Resumo de Atualizações';

  @override
  String get updating => 'Atualizando';

  @override
  String get userName => 'Nome de Utilizador';

  @override
  String versionAvailable(String app, String version) {
    return 'Versão $version disponivel para $app!!';
  }

  @override
  String get webUI => 'Abrir no WEB';

  @override
  String get webView => 'WebView';

  @override
  String get whatsNew => 'O que há de Novo?';

  @override
  String get yesterday => 'Ontem';
}
