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
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navOverflowSheetTitle => 'Go to';

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
  String get pinchToZoomSubtitle =>
      'Horizontal pages only; long-press for magnifier in webtoon mode';

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
  String get readerTapToShowControls =>
      'Tap the center of the screen to show reading controls';

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
  String get readerHaptics => 'Haptic feedback';

  @override
  String get readerHapticsSubtitle =>
      'Vibrate lightly on page and chapter changes';

  @override
  String get readerBrightnessOverlay => 'Reader dimming';

  @override
  String get readerBrightnessOverlaySubtitle =>
      'Darken the screen while reading (does not change system brightness)';

  @override
  String get readerOrientationLock => 'Orientation lock';

  @override
  String get readerOrientationAuto => 'Auto';

  @override
  String get readerOrientationPortrait => 'Portrait';

  @override
  String get readerOrientationLandscape => 'Landscape';

  @override
  String get readerDoublePageSpread => 'Double-page spread';

  @override
  String get readerDoublePageSpreadAuto => 'Automatic (tablet landscape)';

  @override
  String get readerDoublePageSpreadAlways => 'Always';

  @override
  String get readerDoublePageSpreadNever => 'Never';

  @override
  String get readerIOSVolumeHint =>
      'On iOS, use tap zones or the page slider to navigate';

  @override
  String readerResumedPage(int page, int total) {
    return 'Resumed from page $page of $total';
  }

  @override
  String readerPageSliderA11y(int page, int total) {
    return 'Page $page of $total';
  }

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
  String get migrationBatchTitle => 'Batch migration';

  @override
  String migrationSuccessMangaCount(int count) {
    return 'Successfully migrated $count manga.';
  }

  @override
  String migrationPartialFailure(int success, int total, int failed) {
    return 'Migrated $success of $total. $failed failed.';
  }

  @override
  String migrationProgressCount(int current, int total) {
    return '$current of $total';
  }

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
  String get migrationCancelledNoChanges =>
      'Migration cancelled before any changes were applied.';

  @override
  String get migrationCancelledPartial =>
      'Cancel was requested after the server had already applied changes. Check your library — the migration may have completed.';

  @override
  String migrationCancelledPartialBatch(int success, int total) {
    return 'Migration stopped. $success of $total manga had already been migrated.';
  }

  @override
  String get cancelMigrationConfirmationInProgress =>
      'Stop remaining work? A migration already running on the server cannot be undone.';

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
  String get serverUnreachableTitle => 'Server unreachable';

  @override
  String get serverUnreachableBody =>
      'Make sure Suwayomi Server is running and the URL is correct in Settings.';

  @override
  String get serverRetryButton => 'Retry';

  @override
  String get serverOpenSettingsButton => 'Server settings';

  @override
  String get serverOfflineBanner => 'Server offline — tap retry';

  @override
  String get serverOfflineRetryA11y => 'Retry connection';

  @override
  String get serverOfflineDismissA11y => 'Dismiss offline notice';

  @override
  String get notificationsDisabledBanner =>
      'Notifications are off — chapter updates won\'t alert you';

  @override
  String get notificationsOpenSettingsA11y => 'Open notification settings';

  @override
  String get notificationsEnableA11y => 'Enable notifications';

  @override
  String get localDownloadToDevice => 'Download offline to device';

  @override
  String get localDownloadRemoveTooltip => 'Remove offline download';

  @override
  String get localDownloadRetryTooltip => 'Retry offline download';

  @override
  String get localDownloadRemoveTitle => 'Remove offline download?';

  @override
  String get localDownloadRemoveBody =>
      'This chapter will be removed from your device. You can download it again anytime.';

  @override
  String get deleteOfflineDownloadsTitle => 'Delete offline downloads?';

  @override
  String deleteOfflineDownloadsBody(int count) {
    return 'This will remove $count offline chapter(s) from this device.';
  }

  @override
  String get invalidChapterLink => 'Invalid chapter link';

  @override
  String get downloadsTabServer => 'Server';

  @override
  String get downloadsTabOffline => 'Offline';

  @override
  String get downloadsInProgress => 'In progress';

  @override
  String get downloadsQueued => 'Queued';

  @override
  String offlineStorageUsedMb(String size) {
    return '$size MB used on device';
  }

  @override
  String offlineStorageUsedKb(String size) {
    return '$size KB used on device';
  }

  @override
  String migrateSelectedCount(int count) {
    return 'Migrate ($count)';
  }

  @override
  String migrationBatchMatchTitle(String source) {
    return 'Batch match ($source)';
  }

  @override
  String migrationBatchPairing(int count) {
    return 'Automatically pairing $count manga…';
  }

  @override
  String migrationBatchMatchSummary(int matched, int total) {
    return 'Found $matched matches out of $total';
  }

  @override
  String migrationMigrateButtonCount(int count) {
    return 'Migrate $count manga';
  }

  @override
  String get migrationCoverSourceLabel => 'Source';

  @override
  String get migrationCoverMatchLabel => 'Match';

  @override
  String get migrationNoMatch => 'No match';

  @override
  String migrationSearchingInSource(String source, String language) {
    return 'Searching in $source ($language)';
  }

  @override
  String get offlineChapterFallback => 'Chapter';

  @override
  String offlineChapterId(int id) {
    return 'Chapter $id';
  }

  @override
  String get loadingEllipsis => '…';

  @override
  String get readerPagesLoadFailed => 'Could not load chapter pages';

  @override
  String get readerTapPreviousPage => 'Previous page';

  @override
  String get readerTapNextPage => 'Next page';

  @override
  String get readerTapToggleMenu => 'Toggle reader menu';

  @override
  String get globalSearchHint => 'Type to search across all sources';

  @override
  String get seeAll => 'See all';

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
  String get historyContinueReading => 'Continue Reading';

  @override
  String get historyRecent => 'Recent';

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
  String trackerLogOutConfirm(String tracker) {
    return 'Log out from $tracker?';
  }

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
  String get trackingNotSet => '— Not set —';

  @override
  String get trackingStatusReading => 'Reading';

  @override
  String get trackingStatusCompleted => 'Completed';

  @override
  String get trackingStatusOnHold => 'On Hold';

  @override
  String get trackingStatusDropped => 'Dropped';

  @override
  String get trackingStatusPlanToRead => 'Plan to Read';

  @override
  String get trackingStatusRereading => 'Re-reading';

  @override
  String trackingAddForTracker(String tracker) {
    return 'Add Tracking — $tracker';
  }

  @override
  String trackingSearchOnTracker(String tracker) {
    return 'Search on $tracker...';
  }

  @override
  String trackingAddConfirm(String title, String tracker) {
    return 'Track \"$title\" on $tracker?';
  }

  @override
  String trackingChapterCount(int count) {
    return '$count chapters';
  }

  @override
  String get trackingLoginInSettings => 'Log in to a tracker in Settings';

  @override
  String trackingBindLoginRequired(String tracker) {
    return 'Not logged in to $tracker. Go to Settings → Trackers.';
  }

  @override
  String trackingBindEmptyCollection(String tracker) {
    return 'Could not bind — make sure you are logged in to $tracker in Settings → Trackers.';
  }

  @override
  String trackingSearchTimeout(String tracker) {
    return 'Search timed out. $tracker may be slow — please retry.';
  }

  @override
  String get trackingNoInternet => 'No internet connection.';

  @override
  String get trackingDateHint => 'YYYY-MM-DD';

  @override
  String get unknownTracker => 'Tracker';

  @override
  String get mangaRelated => 'Related';

  @override
  String get mangaRecommendations => 'Recommendations';

  @override
  String get appearanceMaterialYou => 'Material You';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceColorScheme => 'Color Scheme';

  @override
  String get appearanceColorSchemeHint =>
      'Used when Dynamic Color is off or unavailable';

  @override
  String get appearanceMaterialSchemes => 'Material Schemes';

  @override
  String get appearanceKomikkuCustomSchemes => 'Komikku Custom Schemes';

  @override
  String get appearanceDynamicColor => 'Dynamic Color';

  @override
  String get appearanceDynamicColorSubtitle =>
      'Use wallpaper colors (Android 12+)';

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

  @override
  String get addCategory => 'Add Category';

  @override
  String get addToLibrary => 'Add to Library';

  @override
  String get advanced => 'Advanced';

  @override
  String get allScanlators => 'All Scanlators';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appTheme => 'App Theme Mode';

  @override
  String get appTitle => 'Catalyst';

  @override
  String get appearance => 'Appearance';

  @override
  String get authType => 'Authentication Type';

  @override
  String get authTypeBasic => 'Basic Auth';

  @override
  String get authTypeNone => 'None';

  @override
  String get authentication => 'Authentication';

  @override
  String get autoDownload => 'Auto-download';

  @override
  String get autoDownloadNewChapters => 'Download new chapters';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get automaticUpdate => 'Automatic Update';

  @override
  String get automaticallyRefreshMetadata => 'Automatically refresh metadata';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Check for new cover and details when updating library';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get backupAndRestore => 'Backup and Restore';

  @override
  String get backupCleanup => 'Backup Cleanup';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Delete Backups that are older 1 day',
        'other': 'Delete Backups that are older $count days',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'Backup Interval';

  @override
  String get backupLocation => 'Backup Location';

  @override
  String get backupLocationDescription =>
      'The path to the directory on the server where automated backups should get saved in';

  @override
  String get backupTime => 'Backup Time';

  @override
  String get badges => 'Badges';

  @override
  String get bookmarked => 'Bookmarked';

  @override
  String get browse => 'Browse';

  @override
  String get buildTime => 'Build time';

  @override
  String get cacheCleared => 'Cache Cleared';

  @override
  String get cancel => 'Cancel';

  @override
  String get categories => 'Categories';

  @override
  String get categoryUpdate => 'Category Update';

  @override
  String get channel => 'Channel';

  @override
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

  @override
  String chapterNumber(double number) {
    return 'Chapter $number';
  }

  @override
  String get chapterSortFetchedDate => 'By Fetched Date';

  @override
  String get chapterSortSource => 'By Source';

  @override
  String get chapterSortUploadDate => 'By Upload Date';

  @override
  String get checkForServerUpdates => 'Check for Server updates';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get client => 'Client';

  @override
  String get clientVersion => 'Client version';

  @override
  String get close => 'Close';

  @override
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Completed';

  @override
  String get copied => 'Copied!';

  @override
  String copyMsg(String msg) {
    return '\'$msg\' Copied!';
  }

  @override
  String get createBackupDescription => 'Backup library as a Tachidesk backup';

  @override
  String get createBackupTitle => 'Create Backup';

  @override
  String get credentials => 'Credentials';

  @override
  String get current => 'Current';

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get debugLogs => 'Debug logs';

  @override
  String get defaultCategory =>
      'Default category when adding new manga to library';

  @override
  String get delete => 'Delete';

  @override
  String get deleteCategoryDescription =>
      'This will merge all Mangas in this Category to Default!';

  @override
  String get deleteCategoryTitle => 'Are you sure?';

  @override
  String get discord => 'Discord';

  @override
  String get display => 'Display';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get displayModeDescriptiveList => 'Descriptive List';

  @override
  String get displayModeGrid => 'Grid';

  @override
  String get displayModeList => 'List';

  @override
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Downloads';

  @override
  String get edit => 'Edit';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get emptyCategory => 'Category name can\'t be Empty';

  @override
  String get enableSocksProxy => 'Use SOCKS Proxy';

  @override
  String enterProp(Object prop) {
    return 'Enter $prop';
  }

  @override
  String get error => 'Error';

  @override
  String get errorBackupCreate => 'Failed to create Backup';

  @override
  String get errorBackupRestore => 'Failed to restore backup!';

  @override
  String get errorExtension => 'Can\'t find the selected extension';

  @override
  String get errorFilePick => 'File not selected!';

  @override
  String errorFilePickUnknownExtension(Object extensionName) {
    return 'Please select a file with $extensionName extension';
  }

  @override
  String errorLaunchURL(String url) {
    return 'Failed to open!\nCopying \"$url\" to clipboard';
  }

  @override
  String get errorPassword => 'Password can\'t be empty';

  @override
  String get errorSomethingWentWrong => 'Something went wrong!';

  @override
  String get errorUserName => 'UserName can\'t be empty';

  @override
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Extension Installed!';

  @override
  String get extensionListEmpty => 'Extension list is Empty';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

  @override
  String get extensions => 'Extensions';

  @override
  String get failed => 'Failed';

  @override
  String get filter => 'Filter';

  @override
  String get findServer => 'Find';

  @override
  String get finished => 'Finished';

  @override
  String get flareSolverr => 'FlareSolverr';

  @override
  String get flareSolverrRequestTimeout => 'FlareSolverr Request Timeout';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr Server Url';

  @override
  String get flareSolverrSessionName => 'FlareSolverr session name';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr session TTL';

  @override
  String get general => 'General';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Global Search';

  @override
  String get globalUpdate => 'Global Update';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Help';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'In library';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Install';

  @override
  String get installing => 'Installing';

  @override
  String get installingExtension => 'Installing Extension';

  @override
  String get invalidPort => 'Invalid Port';

  @override
  String invalidProp(Object property) {
    return 'Invalid $property';
  }

  @override
  String get ip => 'IP Address';

  @override
  String get ipHintText => 'Enter server binding IP address';

  @override
  String get isTrueBlack => 'True Black';

  @override
  String get languages => 'Languages';

  @override
  String get latest => 'Latest';

  @override
  String get library => 'Library';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

  @override
  String get manga => 'Manga';

  @override
  String get mangaGridSize => 'Manga Grid Size';

  @override
  String get mangaMissingSources => 'Manga Missing Sources';

  @override
  String get mangaSortAlphabetical => 'Alphabetical';

  @override
  String get mangaSortDateAdded => 'Date Added';

  @override
  String get mangaSortLastRead => 'Last Read';

  @override
  String get mangaSortLastUpdated => 'Last Updated';

  @override
  String get mangaSortUnread => 'Unread';

  @override
  String get mangaStatusCancelled => 'Cancelled';

  @override
  String get mangaStatusCompleted => 'Completed';

  @override
  String get mangaStatusLicensed => 'Licensed';

  @override
  String get mangaStatusOnHiatus => 'On Hiatus';

  @override
  String get mangaStatusOngoing => 'Ongoing';

  @override
  String get mangaStatusPublishingFinished => 'Publishing Finished';

  @override
  String get mangaStatusUnknown => 'Unknown';

  @override
  String get misc => 'Misc';

  @override
  String get missingExtension => 'Missing Extensions';

  @override
  String get missingTrackers => 'Missing Trackers';

  @override
  String get more => 'More';

  @override
  String get moveToBottom => 'Move to Bottom';

  @override
  String get moveToTop => 'Move to top';

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
  String get newUpdateAvailable => 'New update available';

  @override
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navOverflowSheetTitle => 'Go to';

  @override
  String nextChapter(Object chapterTitle) {
    return 'Next: $chapterTitle';
  }

  @override
  String get noCategoriesFound =>
      'You don\'t have any Categories. \n(Tip: Tap the Plus button to create one for organizing your library)';

  @override
  String get noCategoriesFoundAlt =>
      'You don\'t have any Categories. \nCreate one in settings for organizing your library';

  @override
  String get noCategoryMangaFound =>
      'No manga found in this Category. \n(Tip: Check your search & filters!)';

  @override
  String get noChaptersFound => 'No Chapters found';

  @override
  String get noDownloads => 'No Downloads';

  @override
  String get noMangaFound => 'No Mangas Found';

  @override
  String noOfChapters(int count) {
    return '$count Chapters';
  }

  @override
  String noPropFound(Object prop) {
    return 'No $prop Found';
  }

  @override
  String get noResultFound => 'No results found';

  @override
  String get noServerFound => 'No Server found in your local network';

  @override
  String get noSourcesFound => 'No sources found';

  @override
  String get noUpdatesAvailable => 'You\'re using the latest version';

  @override
  String get noUpdatesFound => 'No updates found';

  @override
  String get none => 'None';

  @override
  String get nsfw => 'Show NSFW extensions and sources';

  @override
  String get nsfw18 => '18+';

  @override
  String get nsfwInfo =>
      'This does not prevent unofficial or potentially incorrectly flagged extensions from surfacing NSFW(18+) content within app';

  @override
  String numSelected(int num) {
    return '$num Selected';
  }

  @override
  String get obsolete => 'Obsolete';

  @override
  String get openFlareSolverr =>
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Page: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Password';

  @override
  String get pause => 'Pause';

  @override
  String get pending => 'Pending';

  @override
  String get pinchToZoom => 'Pinch to Zoom';

  @override
  String get pinchToZoomSubtitle =>
      'Horizontal pages only; long-press for magnifier in webtoon mode';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Previous: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Quick Search';

  @override
  String get quickSearchCategory => 'Go to Category \'C\'';

  @override
  String get quickSearchCategoryManga => 'Go to Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchCategoryMangaChapter =>
      'Go to Chapter Name \'CN\' from Manga \'M\' in Category \'C\'';

  @override
  String get quickSearchContext =>
      'Search for query X (Results are based on screen context)';

  @override
  String get quickSearchShowAllCommandTip =>
      'Tip: Enter \'?\' to see all commands';

  @override
  String get quickSearchSource => 'Go to Source \'S\'';

  @override
  String get quickSearchSourceManga => 'Search for Manga \'M\' in Source \'S\'';

  @override
  String get reader => 'Reader';

  @override
  String get readerMagnifierSize => 'Magnifier Size';

  @override
  String get readerMode => 'Reading Mode';

  @override
  String get readerModeContinuousHorizontalLTR => 'Continuous Horizontal (LTR)';

  @override
  String get readerModeContinuousHorizontalRTL => 'Continuous Horizontal (RTL)';

  @override
  String get readerModeContinuousVertical => 'Continuous Vertical';

  @override
  String get readerModeDefaultReader => 'Default';

  @override
  String get readerModeSingleHorizontalLTR => 'Single Horizontal (LTR)';

  @override
  String get readerModeSingleHorizontalRTL => 'Single Horizontal (RTL)';

  @override
  String get readerModeSingleVertical => 'Single Vertical';

  @override
  String get readerModeWebtoon => 'Webtoon';

  @override
  String get readerNavigationLayout => 'Navigation layout';

  @override
  String get readerNavigationLayoutDefault => 'Default';

  @override
  String get readerNavigationLayoutDisabled => 'Disabled';

  @override
  String get readerNavigationLayoutEdge => 'Edge';

  @override
  String get readerNavigationLayoutInvert => 'Invert tapping';

  @override
  String get readerNavigationLayoutKindlish => 'Kindle-ish';

  @override
  String get readerNavigationLayoutLShaped => 'L Shaped';

  @override
  String get readerNavigationLayoutRightAndLeft => 'Right And Left';

  @override
  String get readerOverlay => 'Reader initial overlay';

  @override
  String get readerOverlaySubtitle =>
      'Shows title and quick settings when opening a chapter';

  @override
  String get readerTapToShowControls =>
      'Tap the center of the screen to show reading controls';

  @override
  String get readerPadding => 'Reader Padding';

  @override
  String get readerScrollAnimation => 'Scroll animation';

  @override
  String get readerSwipeChapterToggle => 'Swipe toggle';

  @override
  String get readerSwipeChapterToggleDescription =>
      'Swipe to change chapter in reader';

  @override
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Volume Keys';

  @override
  String get readerVolumeTapInvert => 'Invert Volume Keys';

  @override
  String get readerVolumeTapSubtitle => 'Navigate with Volume Keys';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get readerHaptics => 'Haptic feedback';

  @override
  String get readerHapticsSubtitle =>
      'Vibrate lightly on page and chapter changes';

  @override
  String get readerBrightnessOverlay => 'Reader dimming';

  @override
  String get readerBrightnessOverlaySubtitle =>
      'Darken the screen while reading (does not change system brightness)';

  @override
  String get readerOrientationLock => 'Orientation lock';

  @override
  String get readerOrientationAuto => 'Auto';

  @override
  String get readerOrientationPortrait => 'Portrait';

  @override
  String get readerOrientationLandscape => 'Landscape';

  @override
  String get readerDoublePageSpread => 'Double-page spread';

  @override
  String get readerDoublePageSpreadAuto => 'Automatic (tablet landscape)';

  @override
  String get readerDoublePageSpreadAlways => 'Always';

  @override
  String get readerDoublePageSpreadNever => 'Never';

  @override
  String get readerIOSVolumeHint =>
      'On iOS, use tap zones or the page slider to navigate';

  @override
  String readerResumedPage(int page, int total) {
    return 'Resumed from page $page of $total';
  }

  @override
  String readerPageSliderA11y(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Refresh';

  @override
  String get migrate => 'Migrate';

  @override
  String get migrationSelectTargetSource => 'Select Target Source';

  @override
  String migrationSearchInSource(Object sourceName) {
    return 'Search in $sourceName';
  }

  @override
  String get migrationPreview => 'Migration Preview';

  @override
  String get migrationInProgress => 'Migration in Progress';

  @override
  String get migrationBatchTitle => 'Batch migration';

  @override
  String migrationSuccessMangaCount(int count) {
    return 'Successfully migrated $count manga.';
  }

  @override
  String migrationPartialFailure(int success, int total, int failed) {
    return 'Migrated $success of $total. $failed failed.';
  }

  @override
  String migrationProgressCount(int current, int total) {
    return '$current of $total';
  }

  @override
  String get migrationComplete => 'Migration completed successfully';

  @override
  String get migrationFailed => 'Migration Failed';

  @override
  String get migrationCancelled => 'Migration Cancelled';

  @override
  String get migrateChapters => 'Migrate Chapters';

  @override
  String get migrateChaptersDescription =>
      'Copy chapter read status to new source';

  @override
  String get migrateCategories => 'Migrate Categories';

  @override
  String get migrateCategoriesDescription =>
      'Copy manga categories to new source';

  @override
  String get migrateDownloads => 'Migrate Downloads';

  @override
  String get migrateDownloadsDescription =>
      'Move downloaded chapters to new source';

  @override
  String get migrateTracking => 'Migrate Tracking';

  @override
  String get migrateTrackingDescription =>
      'Copy tracking information to new source';

  @override
  String get migrationOptions => 'Migration Options';

  @override
  String get migrationSettings => 'Migration Settings';

  @override
  String get selectTargetSource => 'Select Target Source';

  @override
  String get noSourcesAvailable => 'No sources available for migration';

  @override
  String get checkSourceConfiguration =>
      'Please check your source configuration';

  @override
  String get noAlternativeSources => 'No alternative sources available';

  @override
  String get installMoreSources => 'Install more sources to enable migration';

  @override
  String get errorLoadingSources => 'Error loading sources';

  @override
  String get errorGettingMigrationSources => 'Failed to get migration sources';

  @override
  String get errorSearchingMangaInSource => 'Failed to search manga in source';

  @override
  String get errorFetchingSourceManga => 'Failed to fetch source manga';

  @override
  String get errorSourceMangaNotFound => 'Source manga not found';

  @override
  String get errorFetchingTargetManga => 'Failed to fetch target manga';

  @override
  String get errorTargetMangaNotFound => 'Target manga not found';

  @override
  String get searchManga => 'Search manga...';

  @override
  String get searchForManga => 'Search for manga in the target source';

  @override
  String get enterSearchTerm => 'Enter a search term to find manga';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get searchError => 'Search error';

  @override
  String get importantNotice => 'Important Notice';

  @override
  String get migrationWarning =>
      'This will permanently move your manga data. This action cannot be undone.';

  @override
  String get deleteSourceWarning =>
      'The original manga will be removed from your library after migration.';

  @override
  String get confirmMigration => 'Confirm Migration';

  @override
  String get migrationConfirmationMessage =>
      'Are you sure you want to migrate this manga? This action cannot be undone.';

  @override
  String get startMigration => 'Start Migration';

  @override
  String get preparingMigration => 'Preparing migration...';

  @override
  String get migrationCompleted => 'Migration Completed!';

  @override
  String get migrationSuccessMessage =>
      'Your manga has been successfully migrated to the new source.';

  @override
  String get migrationCancelledMessage =>
      'The migration process has been cancelled. No changes were made.';

  @override
  String get migrationCancelledNoChanges =>
      'Migration cancelled before any changes were applied.';

  @override
  String get migrationCancelledPartial =>
      'Cancel was requested after the server had already applied changes. Check your library — the migration may have completed.';

  @override
  String migrationCancelledPartialBatch(int success, int total) {
    return 'Migration stopped. $success of $total manga had already been migrated.';
  }

  @override
  String get cancelMigrationConfirmationInProgress =>
      'Stop remaining work? A migration already running on the server cannot be undone.';

  @override
  String get cancelMigration => 'Cancel Migration';

  @override
  String get cancelMigrationConfirmation =>
      'Are you sure you want to cancel the migration? This action cannot be undone.';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get quickMigration => 'Quick';

  @override
  String get fullMigration => 'Full';

  @override
  String get customMigration => 'Custom';

  @override
  String get deleteSourceManga => 'Delete Source Manga';

  @override
  String get deleteSourceMangaDescription =>
      'Remove the original manga from library after migration';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get source => 'Source';

  @override
  String get migrationDetails => 'Migration Details';

  @override
  String get searchAllSources => 'Search All Sources';

  @override
  String get searchingAllSources => 'Searching across all available sources...';

  @override
  String get noMatchingMangaFound => 'No matching manga found in any source';

  @override
  String get deleteSourceAfterMigration =>
      'Delete source manga after migration';

  @override
  String get reload => 'Reload';

  @override
  String get remove => 'Remove';

  @override
  String get removeFromLibrary => 'Remove from Library?';

  @override
  String get reset => 'Reset';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupDescription => 'Restore Tachidesk from backup';

  @override
  String get restoreBackupTitle => 'Restore Backup';

  @override
  String get restored => 'Backup restored!';

  @override
  String get restoring => 'Restoring backup';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get running => 'Running';

  @override
  String get save => 'Save';

  @override
  String get saveAsCBZArchive => 'Save as CBZ archive';

  @override
  String get scanlators => 'Scanlators';

  @override
  String get search => 'Search';

  @override
  String get searchingForUpdates => 'Searching for updates';

  @override
  String get selectInBetween => 'Select in between';

  @override
  String get selectNext10 => 'Select next 10';

  @override
  String get selectUnread => 'Select Unread';

  @override
  String get server => 'Server';

  @override
  String get serverBindings => 'Server Bindings';

  @override
  String get serverPort => 'Server Port';

  @override
  String get serverPortHintText => 'Server port';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHintText => 'Server url';

  @override
  String get serverVersion => 'Server version';

  @override
  String get serverUnreachableTitle => 'Server unreachable';

  @override
  String get serverUnreachableBody =>
      'Make sure Suwayomi Server is running and the URL is correct in Settings.';

  @override
  String get serverRetryButton => 'Retry';

  @override
  String get serverOpenSettingsButton => 'Server settings';

  @override
  String get serverOfflineBanner => 'Server offline — tap retry';

  @override
  String get serverOfflineRetryA11y => 'Retry connection';

  @override
  String get serverOfflineDismissA11y => 'Dismiss offline notice';

  @override
  String get notificationsDisabledBanner =>
      'Notifications are off — chapter updates won\'t alert you';

  @override
  String get notificationsOpenSettingsA11y => 'Open notification settings';

  @override
  String get notificationsEnableA11y => 'Enable notifications';

  @override
  String get localDownloadToDevice => 'Download offline to device';

  @override
  String get localDownloadRemoveTooltip => 'Remove offline download';

  @override
  String get localDownloadRetryTooltip => 'Retry offline download';

  @override
  String get localDownloadRemoveTitle => 'Remove offline download?';

  @override
  String get localDownloadRemoveBody =>
      'This chapter will be removed from your device. You can download it again anytime.';

  @override
  String get deleteOfflineDownloadsTitle => 'Delete offline downloads?';

  @override
  String deleteOfflineDownloadsBody(int count) {
    return 'This will remove $count offline chapter(s) from this device.';
  }

  @override
  String get invalidChapterLink => 'Invalid chapter link';

  @override
  String get downloadsTabServer => 'Server';

  @override
  String get downloadsTabOffline => 'Offline';

  @override
  String get downloadsInProgress => 'In progress';

  @override
  String get downloadsQueued => 'Queued';

  @override
  String offlineStorageUsedMb(String size) {
    return '$size MB used on device';
  }

  @override
  String offlineStorageUsedKb(String size) {
    return '$size KB used on device';
  }

  @override
  String migrateSelectedCount(int count) {
    return 'Migrate ($count)';
  }

  @override
  String migrationBatchMatchTitle(String source) {
    return 'Batch match ($source)';
  }

  @override
  String migrationBatchPairing(int count) {
    return 'Automatically pairing $count manga…';
  }

  @override
  String migrationBatchMatchSummary(int matched, int total) {
    return 'Found $matched matches out of $total';
  }

  @override
  String migrationMigrateButtonCount(int count) {
    return 'Migrate $count manga';
  }

  @override
  String get migrationCoverSourceLabel => 'Source';

  @override
  String get migrationCoverMatchLabel => 'Match';

  @override
  String get migrationNoMatch => 'No match';

  @override
  String migrationSearchingInSource(String source, String language) {
    return 'Searching in $source ($language)';
  }

  @override
  String get offlineChapterFallback => 'Chapter';

  @override
  String offlineChapterId(int id) {
    return 'Chapter $id';
  }

  @override
  String get loadingEllipsis => '…';

  @override
  String get readerPagesLoadFailed => 'Could not load chapter pages';

  @override
  String get readerTapPreviousPage => 'Previous page';

  @override
  String get readerTapNextPage => 'Next page';

  @override
  String get readerTapToggleMenu => 'Toggle reader menu';

  @override
  String get globalSearchHint => 'Type to search across all sources';

  @override
  String get seeAll => 'See all';

  @override
  String get settings => 'Settings';

  @override
  String get skipUpdatingEntries => 'Skip updating entries';

  @override
  String get socksHost => 'SOCKS Host';

  @override
  String get socksPassword => 'SOCKS Password';

  @override
  String get socksPort => 'SOCKS Port';

  @override
  String get socksProxy => 'SOCKS Proxy';

  @override
  String get socksUserName => 'SOCKS UserName';

  @override
  String get socksVersion => 'SOCKS Version';

  @override
  String get sort => 'Sort';

  @override
  String get sourceTypeFilter => 'Filter';

  @override
  String get sourceTypeLatest => 'Latest';

  @override
  String get sourceTypePopular => 'Popular';

  @override
  String get sources => 'Sources';

  @override
  String get start => 'Start';

  @override
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get today => 'Today';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get uninstalling => 'Uninstalling';

  @override
  String get unknownAuthor => 'Unknown Author';

  @override
  String get unknownManga => 'Unknown Manga';

  @override
  String get unknownSource => 'Unknown Source';

  @override
  String get unread => 'Unread';

  @override
  String get update => 'Update';

  @override
  String get updateCompleted => 'Update Completed';

  @override
  String updateFailed(Object property) {
    return 'Failed to update $property';
  }

  @override
  String get updates => 'Updates';

  @override
  String get updatesSummary => 'Updates Summary';

  @override
  String get updating => 'Updating';

  @override
  String get userName => 'User Name';

  @override
  String get validating => 'Validating';

  @override
  String versionAvailable(String app, String version) {
    return 'Version $version available for $app!!';
  }

  @override
  String get webUI => 'Open in WEB';

  @override
  String get webView => 'Web View';

  @override
  String get whatsNew => 'What\'s New?';

  @override
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get recentlyRead => 'Recently Read';

  @override
  String get history => 'History';

  @override
  String get historyContinueReading => 'Continue Reading';

  @override
  String get historyRecent => 'Recent';

  @override
  String get searchHistory => 'Search history...';

  @override
  String get noHistoryFound => 'No reading history found';

  @override
  String get startReadingToSeeHistory =>
      'Start reading manga to see your history here';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get viewManga => 'View Manga';

  @override
  String get removeFromHistory => 'Remove from History';

  @override
  String get removeFromHistoryConfirmation =>
      'Are you sure you want to remove this chapter from your reading history?';

  @override
  String get timeoutSettings => 'Timeout Settings';

  @override
  String get serverRequestTimeout => 'Server Request Timeout';

  @override
  String get serverRequestTimeoutDescription =>
      'Time to wait for server responses (in seconds)';

  @override
  String get autoRefreshOnTimeout => 'Auto-refresh on Timeout';

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
  String trackerLogOutConfirm(String tracker) {
    return 'Log out from $tracker?';
  }

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
  String get trackingNotSet => '— Not set —';

  @override
  String get trackingStatusReading => 'Reading';

  @override
  String get trackingStatusCompleted => 'Completed';

  @override
  String get trackingStatusOnHold => 'On Hold';

  @override
  String get trackingStatusDropped => 'Dropped';

  @override
  String get trackingStatusPlanToRead => 'Plan to Read';

  @override
  String get trackingStatusRereading => 'Re-reading';

  @override
  String trackingAddForTracker(String tracker) {
    return 'Add Tracking — $tracker';
  }

  @override
  String trackingSearchOnTracker(String tracker) {
    return 'Search on $tracker...';
  }

  @override
  String trackingAddConfirm(String title, String tracker) {
    return 'Track \"$title\" on $tracker?';
  }

  @override
  String trackingChapterCount(int count) {
    return '$count chapters';
  }

  @override
  String get trackingLoginInSettings => 'Log in to a tracker in Settings';

  @override
  String trackingBindLoginRequired(String tracker) {
    return 'Not logged in to $tracker. Go to Settings → Trackers.';
  }

  @override
  String trackingBindEmptyCollection(String tracker) {
    return 'Could not bind — make sure you are logged in to $tracker in Settings → Trackers.';
  }

  @override
  String trackingSearchTimeout(String tracker) {
    return 'Search timed out. $tracker may be slow — please retry.';
  }

  @override
  String get trackingNoInternet => 'No internet connection.';

  @override
  String get trackingDateHint => 'YYYY-MM-DD';

  @override
  String get unknownTracker => 'Tracker';

  @override
  String get mangaRelated => 'Related';

  @override
  String get mangaRecommendations => 'Recommendations';

  @override
  String get appearanceMaterialYou => 'Material You';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceColorScheme => 'Color Scheme';

  @override
  String get appearanceColorSchemeHint =>
      'Used when Dynamic Color is off or unavailable';

  @override
  String get appearanceMaterialSchemes => 'Material Schemes';

  @override
  String get appearanceKomikkuCustomSchemes => 'Komikku Custom Schemes';

  @override
  String get appearanceDynamicColor => 'Dynamic Color';

  @override
  String get appearanceDynamicColorSubtitle =>
      'Use wallpaper colors (Android 12+)';

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
  String get advanced => 'Advanced';

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
  String get authentication => 'Authentication';

  @override
  String get autoDownload => 'Auto-download';

  @override
  String get autoDownloadNewChapters => 'Download new chapters';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get automaticUpdate => 'Automatic Update';

  @override
  String get automaticallyRefreshMetadata => 'Automatically refresh metadata';

  @override
  String get automaticallyRefreshMetadataSubtitle =>
      'Check for new cover and details when updating library';

  @override
  String get backup => 'Cópia de segurança e restaurar';

  @override
  String get backupAndRestore => 'Backup and Restore';

  @override
  String get backupCleanup => 'Backup Cleanup';

  @override
  String backupCleanupDescription(String count) {
    String _temp0 = intl.Intl.selectLogic(
      count,
      {
        '0': 'Never',
        '01': 'Delete Backups that are older 1 day',
        'other': 'Delete Backups that are older $count days',
      },
    );
    return '$_temp0';
  }

  @override
  String get backupInterval => 'Backup Interval';

  @override
  String get backupLocation => 'Backup Location';

  @override
  String get backupLocationDescription =>
      'The path to the directory on the server where automated backups should get saved in';

  @override
  String get backupTime => 'Backup Time';

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
  String get chapterDownloadLimit => 'Chapter download limit';

  @override
  String get chapterDownloadLimitDesc =>
      'Limit the amount of new chapters that are going to get downloaded.';

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
  String get cloudflareBypass => 'Cloudflare Bypass';

  @override
  String get completed => 'Completo';

  @override
  String get copied => 'Copied!';

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
  String get debugLogs => 'Debug logs';

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
  String get downloadLocation => 'Download location';

  @override
  String get downloadLocationHint =>
      'The path to the directory on the server where downloaded files should get saved in';

  @override
  String get downloaded => 'Transferidos';

  @override
  String get downloading => 'Downloading';

  @override
  String get downloads => 'Transferências';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar Categoria';

  @override
  String get emptyCategory => 'Nome da categoria não pode ficar em branco';

  @override
  String get enableSocksProxy => 'Use SOCKS Proxy';

  @override
  String enterProp(Object prop) {
    return 'Enter $prop';
  }

  @override
  String get error => 'Error';

  @override
  String get errorBackupCreate => 'Failed to create Backup';

  @override
  String get errorBackupRestore => 'Failed to restore backup!';

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
  String get excludeEntryWithUnreadChapters =>
      'Ignore automatic chapter downloads for entries with unread chapters';

  @override
  String get extensionInstalled => 'Extensão instalada!';

  @override
  String get extensionListEmpty => 'Lista de extensão está vazia';

  @override
  String get extensionRepository => 'Extension Repository';

  @override
  String get extensionRepositoryDescription =>
      'Add repositories from which extensions can be installed';

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
  String get flareSolverrRequestTimeout => 'FlareSolverr Request Timeout';

  @override
  String get flareSolverrServerUrl => 'FlareSolverr Server Url';

  @override
  String get flareSolverrSessionName => 'FlareSolverr session name';

  @override
  String get flareSolverrSessionTTL => 'FlareSolverr session TTL';

  @override
  String get general => 'Geral';

  @override
  String get gitHub => 'GitHub';

  @override
  String get globalSearch => 'Procura global';

  @override
  String get globalUpdate => 'Atualização global';

  @override
  String get gqlDebugLogs => 'Graphql debug logs';

  @override
  String get gqlDebugLogsHint =>
      'This includes logs with non privacy safe information';

  @override
  String get help => 'Ajuda';

  @override
  String get hideEmptyCategory => 'Hide Empty Category';

  @override
  String get inLibrary => 'Na Biblioteca';

  @override
  String get includeCategories => 'Categories';

  @override
  String get includeChapters => 'Chapters';

  @override
  String get install => 'Instalar';

  @override
  String get installing => 'A Instalar';

  @override
  String get installingExtension => 'A instalar extensões';

  @override
  String get invalidPort => 'Invalid Port';

  @override
  String invalidProp(Object property) {
    return 'Invalid $property';
  }

  @override
  String get ip => 'IP Address';

  @override
  String get ipHintText => 'Enter server binding IP address';

  @override
  String get isTrueBlack => 'True Black';

  @override
  String get languages => 'Idiomas';

  @override
  String get latest => 'Mais recente';

  @override
  String get library => 'Biblioteca';

  @override
  String get localSourceLocation => 'Local source location';

  @override
  String get localSourceLocationDescription =>
      'The path to the directory on the server where local source files are saved in';

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
  String get mangaSortLastUpdated => 'Last Updated';

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
  String get misc => 'Misc';

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
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navOverflowSheetTitle => 'Go to';

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
  String noPropFound(Object prop) {
    return 'No $prop Found';
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
  String get none => 'None';

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
      'Checkout FlareSolverr for information on how to set it up';

  @override
  String get openInWeb => 'Open In Web';

  @override
  String get or => 'or';

  @override
  String page(int number) {
    return 'Página: $number';
  }

  @override
  String get parallelSourceRequest => 'Parallel source requests';

  @override
  String get password => 'Senha';

  @override
  String get pause => 'Pausa';

  @override
  String get pending => 'Pendente';

  @override
  String get pinchToZoom => 'Pinch to Zoom';

  @override
  String get pinchToZoomSubtitle =>
      'Horizontal pages only; long-press for magnifier in webtoon mode';

  @override
  String previousChapter(Object chapterTitle) {
    return 'Anterior: $chapterTitle';
  }

  @override
  String get queued => 'Queued';

  @override
  String get quickSearch => 'Quick Search';

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
  String get readerTapToShowControls =>
      'Tap the center of the screen to show reading controls';

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
  String get readerLastPageSwipeToggle => 'Last page swipe';

  @override
  String get readerLastPageSwipeToggleDescription =>
      'Swipe to next chapter only at last page';

  @override
  String get readerVolumeTap => 'Teclas de volume';

  @override
  String get readerVolumeTapInvert => 'Inverter teclas de volume';

  @override
  String get readerVolumeTapSubtitle => 'Navegar com teclas de volume';

  @override
  String get readerIgnoreSafeAreaToggle => 'Ignore Safe Area';

  @override
  String get readerIgnoreSafeAreaToggleDescription =>
      'Allow content to extend into notch and home indicator areas';

  @override
  String get readerHaptics => 'Haptic feedback';

  @override
  String get readerHapticsSubtitle =>
      'Vibrate lightly on page and chapter changes';

  @override
  String get readerBrightnessOverlay => 'Reader dimming';

  @override
  String get readerBrightnessOverlaySubtitle =>
      'Darken the screen while reading (does not change system brightness)';

  @override
  String get readerOrientationLock => 'Orientation lock';

  @override
  String get readerOrientationAuto => 'Auto';

  @override
  String get readerOrientationPortrait => 'Portrait';

  @override
  String get readerOrientationLandscape => 'Landscape';

  @override
  String get readerDoublePageSpread => 'Double-page spread';

  @override
  String get readerDoublePageSpreadAuto => 'Automatic (tablet landscape)';

  @override
  String get readerDoublePageSpreadAlways => 'Always';

  @override
  String get readerDoublePageSpreadNever => 'Never';

  @override
  String get readerIOSVolumeHint =>
      'On iOS, use tap zones or the page slider to navigate';

  @override
  String readerResumedPage(int page, int total) {
    return 'Resumed from page $page of $total';
  }

  @override
  String readerPageSliderA11y(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get reddit => 'Reddit';

  @override
  String get refresh => 'Recarregar';

  @override
  String get migrate => 'Migrate';

  @override
  String get migrationSelectTargetSource => 'Select Target Source';

  @override
  String migrationSearchInSource(Object sourceName) {
    return 'Search in $sourceName';
  }

  @override
  String get migrationPreview => 'Migration Preview';

  @override
  String get migrationInProgress => 'Migration in Progress';

  @override
  String get migrationBatchTitle => 'Batch migration';

  @override
  String migrationSuccessMangaCount(int count) {
    return 'Successfully migrated $count manga.';
  }

  @override
  String migrationPartialFailure(int success, int total, int failed) {
    return 'Migrated $success of $total. $failed failed.';
  }

  @override
  String migrationProgressCount(int current, int total) {
    return '$current of $total';
  }

  @override
  String get migrationComplete => 'Migration completed successfully';

  @override
  String get migrationFailed => 'Migration Failed';

  @override
  String get migrationCancelled => 'Migration Cancelled';

  @override
  String get migrateChapters => 'Migrate Chapters';

  @override
  String get migrateChaptersDescription =>
      'Copy chapter read status to new source';

  @override
  String get migrateCategories => 'Migrate Categories';

  @override
  String get migrateCategoriesDescription =>
      'Copy manga categories to new source';

  @override
  String get migrateDownloads => 'Migrate Downloads';

  @override
  String get migrateDownloadsDescription =>
      'Move downloaded chapters to new source';

  @override
  String get migrateTracking => 'Migrate Tracking';

  @override
  String get migrateTrackingDescription =>
      'Copy tracking information to new source';

  @override
  String get migrationOptions => 'Migration Options';

  @override
  String get migrationSettings => 'Migration Settings';

  @override
  String get selectTargetSource => 'Select Target Source';

  @override
  String get noSourcesAvailable => 'No sources available for migration';

  @override
  String get checkSourceConfiguration =>
      'Please check your source configuration';

  @override
  String get noAlternativeSources => 'No alternative sources available';

  @override
  String get installMoreSources => 'Install more sources to enable migration';

  @override
  String get errorLoadingSources => 'Error loading sources';

  @override
  String get errorGettingMigrationSources => 'Failed to get migration sources';

  @override
  String get errorSearchingMangaInSource => 'Failed to search manga in source';

  @override
  String get errorFetchingSourceManga => 'Failed to fetch source manga';

  @override
  String get errorSourceMangaNotFound => 'Source manga not found';

  @override
  String get errorFetchingTargetManga => 'Failed to fetch target manga';

  @override
  String get errorTargetMangaNotFound => 'Target manga not found';

  @override
  String get searchManga => 'Search manga...';

  @override
  String get searchForManga => 'Search for manga in the target source';

  @override
  String get enterSearchTerm => 'Enter a search term to find manga';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get searchError => 'Search error';

  @override
  String get importantNotice => 'Important Notice';

  @override
  String get migrationWarning =>
      'This will permanently move your manga data. This action cannot be undone.';

  @override
  String get deleteSourceWarning =>
      'The original manga will be removed from your library after migration.';

  @override
  String get confirmMigration => 'Confirm Migration';

  @override
  String get migrationConfirmationMessage =>
      'Are you sure you want to migrate this manga? This action cannot be undone.';

  @override
  String get startMigration => 'Start Migration';

  @override
  String get preparingMigration => 'Preparing migration...';

  @override
  String get migrationCompleted => 'Migration Completed!';

  @override
  String get migrationSuccessMessage =>
      'Your manga has been successfully migrated to the new source.';

  @override
  String get migrationCancelledMessage =>
      'The migration process has been cancelled. No changes were made.';

  @override
  String get migrationCancelledNoChanges =>
      'Migration cancelled before any changes were applied.';

  @override
  String get migrationCancelledPartial =>
      'Cancel was requested after the server had already applied changes. Check your library — the migration may have completed.';

  @override
  String migrationCancelledPartialBatch(int success, int total) {
    return 'Migration stopped. $success of $total manga had already been migrated.';
  }

  @override
  String get cancelMigrationConfirmationInProgress =>
      'Stop remaining work? A migration already running on the server cannot be undone.';

  @override
  String get cancelMigration => 'Cancel Migration';

  @override
  String get cancelMigrationConfirmation =>
      'Are you sure you want to cancel the migration? This action cannot be undone.';

  @override
  String get quickPresets => 'Quick Presets';

  @override
  String get quickMigration => 'Quick';

  @override
  String get fullMigration => 'Full';

  @override
  String get customMigration => 'Custom';

  @override
  String get deleteSourceManga => 'Delete Source Manga';

  @override
  String get deleteSourceMangaDescription =>
      'Remove the original manga from library after migration';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get source => 'Fonte';

  @override
  String get migrationDetails => 'Migration Details';

  @override
  String get searchAllSources => 'Search All Sources';

  @override
  String get searchingAllSources => 'Searching across all available sources...';

  @override
  String get noMatchingMangaFound => 'No matching manga found in any source';

  @override
  String get deleteSourceAfterMigration =>
      'Delete source manga after migration';

  @override
  String get reload => 'recarregar';

  @override
  String get remove => 'Remover';

  @override
  String get removeFromLibrary => 'Remover da Biblioteca?';

  @override
  String get reset => 'Reiniciar';

  @override
  String get restore => 'Restore';

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
  String get saveAsCBZArchive => 'Save as CBZ archive';

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
  String get serverBindings => 'Server Bindings';

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
  String get serverUnreachableTitle => 'Server unreachable';

  @override
  String get serverUnreachableBody =>
      'Make sure Suwayomi Server is running and the URL is correct in Settings.';

  @override
  String get serverRetryButton => 'Retry';

  @override
  String get serverOpenSettingsButton => 'Server settings';

  @override
  String get serverOfflineBanner => 'Server offline — tap retry';

  @override
  String get serverOfflineRetryA11y => 'Retry connection';

  @override
  String get serverOfflineDismissA11y => 'Dismiss offline notice';

  @override
  String get notificationsDisabledBanner =>
      'Notifications are off — chapter updates won\'t alert you';

  @override
  String get notificationsOpenSettingsA11y => 'Open notification settings';

  @override
  String get notificationsEnableA11y => 'Enable notifications';

  @override
  String get localDownloadToDevice => 'Download offline to device';

  @override
  String get localDownloadRemoveTooltip => 'Remove offline download';

  @override
  String get localDownloadRetryTooltip => 'Retry offline download';

  @override
  String get localDownloadRemoveTitle => 'Remove offline download?';

  @override
  String get localDownloadRemoveBody =>
      'This chapter will be removed from your device. You can download it again anytime.';

  @override
  String get deleteOfflineDownloadsTitle => 'Delete offline downloads?';

  @override
  String deleteOfflineDownloadsBody(int count) {
    return 'This will remove $count offline chapter(s) from this device.';
  }

  @override
  String get invalidChapterLink => 'Invalid chapter link';

  @override
  String get downloadsTabServer => 'Server';

  @override
  String get downloadsTabOffline => 'Offline';

  @override
  String get downloadsInProgress => 'In progress';

  @override
  String get downloadsQueued => 'Queued';

  @override
  String offlineStorageUsedMb(String size) {
    return '$size MB used on device';
  }

  @override
  String offlineStorageUsedKb(String size) {
    return '$size KB used on device';
  }

  @override
  String migrateSelectedCount(int count) {
    return 'Migrate ($count)';
  }

  @override
  String migrationBatchMatchTitle(String source) {
    return 'Batch match ($source)';
  }

  @override
  String migrationBatchPairing(int count) {
    return 'Automatically pairing $count manga…';
  }

  @override
  String migrationBatchMatchSummary(int matched, int total) {
    return 'Found $matched matches out of $total';
  }

  @override
  String migrationMigrateButtonCount(int count) {
    return 'Migrate $count manga';
  }

  @override
  String get migrationCoverSourceLabel => 'Source';

  @override
  String get migrationCoverMatchLabel => 'Match';

  @override
  String get migrationNoMatch => 'No match';

  @override
  String migrationSearchingInSource(String source, String language) {
    return 'Searching in $source ($language)';
  }

  @override
  String get offlineChapterFallback => 'Chapter';

  @override
  String offlineChapterId(int id) {
    return 'Chapter $id';
  }

  @override
  String get loadingEllipsis => '…';

  @override
  String get readerPagesLoadFailed => 'Could not load chapter pages';

  @override
  String get readerTapPreviousPage => 'Previous page';

  @override
  String get readerTapNextPage => 'Next page';

  @override
  String get readerTapToggleMenu => 'Toggle reader menu';

  @override
  String get globalSearchHint => 'Type to search across all sources';

  @override
  String get seeAll => 'See all';

  @override
  String get settings => 'Definições';

  @override
  String get skipUpdatingEntries => 'Skip updating entries';

  @override
  String get socksHost => 'SOCKS Host';

  @override
  String get socksPassword => 'SOCKS Password';

  @override
  String get socksPort => 'SOCKS Port';

  @override
  String get socksProxy => 'SOCKS Proxy';

  @override
  String get socksUserName => 'SOCKS UserName';

  @override
  String get socksVersion => 'SOCKS Version';

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
  String get systemTrayIcon => 'Show icon in system tray';

  @override
  String get thatHaventBeenStarted => 'That haven\'t been started';

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
    return 'Failed to update $property';
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
  String get validating => 'Validating';

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
  String get withCompletedStatus => 'With Completed status';

  @override
  String get withUnreadChapter => 'With unread chapter(s)';

  @override
  String get yesterday => 'Ontem';

  @override
  String get recentlyRead => 'Recently Read';

  @override
  String get history => 'History';

  @override
  String get historyContinueReading => 'Continue Reading';

  @override
  String get historyRecent => 'Recent';

  @override
  String get searchHistory => 'Search history...';

  @override
  String get noHistoryFound => 'No reading history found';

  @override
  String get startReadingToSeeHistory =>
      'Start reading manga to see your history here';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get viewManga => 'View Manga';

  @override
  String get removeFromHistory => 'Remove from History';

  @override
  String get removeFromHistoryConfirmation =>
      'Are you sure you want to remove this chapter from your reading history?';

  @override
  String get timeoutSettings => 'Timeout Settings';

  @override
  String get serverRequestTimeout => 'Server Request Timeout';

  @override
  String get serverRequestTimeoutDescription =>
      'Time to wait for server responses (in seconds)';

  @override
  String get autoRefreshOnTimeout => 'Auto-refresh on Timeout';

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
  String trackerLogOutConfirm(String tracker) {
    return 'Log out from $tracker?';
  }

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
  String get trackingNotSet => '— Not set —';

  @override
  String get trackingStatusReading => 'Reading';

  @override
  String get trackingStatusCompleted => 'Completed';

  @override
  String get trackingStatusOnHold => 'On Hold';

  @override
  String get trackingStatusDropped => 'Dropped';

  @override
  String get trackingStatusPlanToRead => 'Plan to Read';

  @override
  String get trackingStatusRereading => 'Re-reading';

  @override
  String trackingAddForTracker(String tracker) {
    return 'Add Tracking — $tracker';
  }

  @override
  String trackingSearchOnTracker(String tracker) {
    return 'Search on $tracker...';
  }

  @override
  String trackingAddConfirm(String title, String tracker) {
    return 'Track \"$title\" on $tracker?';
  }

  @override
  String trackingChapterCount(int count) {
    return '$count chapters';
  }

  @override
  String get trackingLoginInSettings => 'Log in to a tracker in Settings';

  @override
  String trackingBindLoginRequired(String tracker) {
    return 'Not logged in to $tracker. Go to Settings → Trackers.';
  }

  @override
  String trackingBindEmptyCollection(String tracker) {
    return 'Could not bind — make sure you are logged in to $tracker in Settings → Trackers.';
  }

  @override
  String trackingSearchTimeout(String tracker) {
    return 'Search timed out. $tracker may be slow — please retry.';
  }

  @override
  String get trackingNoInternet => 'No internet connection.';

  @override
  String get trackingDateHint => 'YYYY-MM-DD';

  @override
  String get unknownTracker => 'Tracker';

  @override
  String get mangaRelated => 'Related';

  @override
  String get mangaRecommendations => 'Recommendations';

  @override
  String get appearanceMaterialYou => 'Material You';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceColorScheme => 'Color Scheme';

  @override
  String get appearanceColorSchemeHint =>
      'Used when Dynamic Color is off or unavailable';

  @override
  String get appearanceMaterialSchemes => 'Material Schemes';

  @override
  String get appearanceKomikkuCustomSchemes => 'Komikku Custom Schemes';

  @override
  String get appearanceDynamicColor => 'Dynamic Color';

  @override
  String get appearanceDynamicColorSubtitle =>
      'Use wallpaper colors (Android 12+)';

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
