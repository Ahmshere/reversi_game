/// Поддерживаемые языки
enum AppLanguage {
  english,
  russian,
  hebrew,
  spanish,
  french,
  german,
  chinese,
}

/// Все строки приложения — единственный источник переводов
class AppLocalizations {
  final AppLanguage language;
  const AppLocalizations(this.language);

  static const Map<AppLanguage, String> languageNames = {
    AppLanguage.english: 'English',
    AppLanguage.russian: 'Русский',
    AppLanguage.hebrew: 'עברית',
    AppLanguage.spanish: 'Español',
    AppLanguage.french: 'Français',
    AppLanguage.german: 'Deutsch',
    AppLanguage.chinese: '中文',
  };

  /// Код направления текста (RTL для иврита)
  bool get isRtl => language == AppLanguage.hebrew;

  String get languageName => languageNames[language]!;

  // ── Общее ──────────────────────────────────────────────────────────────────

  String get appTitle => _s(
    en: 'REVERSI',
    ru: 'РЕВЕРСИ',
    he: 'רברסי',
    es: 'REVERSI',
    fr: 'REVERSI',
    de: 'REVERSI',
    zh: '黑白棋',
  );

  String get appSubtitle => _s(
    en: 'Classic Othello',
    ru: 'Классический Отелло',
    he: 'אותלו קלאסי',
    es: 'Othello Clásico',
    fr: 'Othello Classique',
    de: 'Klassisches Othello',
    zh: '经典黑白棋',
  );

  // ── Главное меню ───────────────────────────────────────────────────────────

  String get vsPlayer => _s(
    en: 'VS PLAYER',
    ru: 'ПРОТИВ ИГРОКА',
    he: 'נגד שחקן',
    es: 'VS JUGADOR',
    fr: 'VS JOUEUR',
    de: 'VS SPIELER',
    zh: '双人对战',
  );

  String get vsComputer => _s(
    en: 'VS COMPUTER',
    ru: 'ПРОТИВ КОМПЬЮТЕРА',
    he: 'נגד מחשב',
    es: 'VS COMPUTADORA',
    fr: 'VS ORDINATEUR',
    de: 'VS COMPUTER',
    zh: '对战电脑',
  );

  String get howToPlay => _s(
    en: 'How to Play',
    ru: 'Как играть',
    he: 'איך לשחק',
    es: 'Cómo Jugar',
    fr: 'Comment Jouer',
    de: 'Spielanleitung',
    zh: '游戏规则',
  );

  // ── Экран игры ─────────────────────────────────────────────────────────────

  String get blackPlayer => _s(
    en: 'Black',
    ru: 'Чёрные',
    he: 'שחור',
    es: 'Negro',
    fr: 'Noir',
    de: 'Schwarz',
    zh: '黑棋',
  );

  String get whitePlayer => _s(
    en: 'White',
    ru: 'Белые',
    he: 'לבן',
    es: 'Blanco',
    fr: 'Blanc',
    de: 'Weiß',
    zh: '白棋',
  );

  String turnOf(String playerName) => _s(
    en: '$playerName\'s Turn',
    ru: 'Ход: $playerName',
    he: 'תור $playerName',
    es: 'Turno de $playerName',
    fr: 'Tour de $playerName',
    de: '$playerName ist dran',
    zh: '$playerName 的回合',
  );

  String get noValidMoves => _s(
    en: 'No valid moves! Turn will be skipped.',
    ru: 'Нет доступных ходов! Ход переходит к сопернику.',
    he: 'אין מהלכים! התור עובר ליריב.',
    es: '¡Sin movimientos válidos! Se saltará el turno.',
    fr: 'Pas de mouvements valides ! Le tour sera sauté.',
    de: 'Keine gültigen Züge! Der Zug wird übersprungen.',
    zh: '没有可用的走法！跳过本回合。',
  );

  String get toggleHints => _s(
    en: 'Toggle hints',
    ru: 'Подсказки',
    he: 'רמזים',
    es: 'Alternar pistas',
    fr: 'Basculer les indices',
    de: 'Hinweise umschalten',
    zh: '切换提示',
  );

  String get newGame => _s(
    en: 'New game',
    ru: 'Новая игра',
    he: 'משחק חדש',
    es: 'Nuevo juego',
    fr: 'Nouveau jeu',
    de: 'Neues Spiel',
    zh: '新游戏',
  );

  // ── Диалог новой игры ──────────────────────────────────────────────────────

  String get newGameTitle => _s(
    en: 'New Game',
    ru: 'Новая игра',
    he: 'משחק חדש',
    es: 'Nuevo Juego',
    fr: 'Nouveau Jeu',
    de: 'Neues Spiel',
    zh: '新游戏',
  );

  String get newGameConfirm => _s(
    en: 'Start a new game? Current progress will be lost.',
    ru: 'Начать новую игру? Текущий прогресс будет утерян.',
    he: 'להתחיל משחק חדש? ההתקדמות הנוכחית תאבד.',
    es: '¿Empezar un nuevo juego? El progreso actual se perderá.',
    fr: 'Commencer une nouvelle partie ? La progression actuelle sera perdue.',
    de: 'Neues Spiel starten? Der aktuelle Fortschritt geht verloren.',
    zh: '开始新游戏？当前进度将丢失。',
  );

  String get cancel => _s(
    en: 'CANCEL',
    ru: 'ОТМЕНА',
    he: 'ביטול',
    es: 'CANCELAR',
    fr: 'ANNULER',
    de: 'ABBRECHEN',
    zh: '取消',
  );

  String get confirm => _s(
    en: 'NEW GAME',
    ru: 'НОВАЯ ИГРА',
    he: 'משחק חדש',
    es: 'NUEVO JUEGO',
    fr: 'NOUVEAU JEU',
    de: 'NEUES SPIEL',
    zh: '新游戏',
  );

  // ── Диалог выхода ─────────────────────────────────────────────────────────

  String get leaveGameTitle => _s(
    en: 'Leave game?',
    ru: 'Выйти из игры?',
    he: 'לצאת מהמשחק?',
    es: '¿Salir del juego?',
    fr: 'Quitter la partie ?',
    de: 'Spiel verlassen?',
    zh: '退出游戏？',
  );

  String get leaveGameConfirm => _s(
    en: 'The current game will be lost.',
    ru: 'Текущая партия будет потеряна.',
    he: 'המשחק הנוכחי יאבד.',
    es: 'La partida actual se perderá.',
    fr: 'La partie en cours sera perdue.',
    de: 'Das aktuelle Spiel geht verloren.',
    zh: '当前游戏进度将丢失。',
  );

  String get stay => _s(
    en: 'STAY',
    ru: 'ОСТАТЬСЯ',
    he: 'הישאר',
    es: 'QUEDARSE',
    fr: 'RESTER',
    de: 'BLEIBEN',
    zh: '留下',
  );

  String get leave => _s(
    en: 'LEAVE',
    ru: 'ВЫЙТИ',
    he: 'צא',
    es: 'SALIR',
    fr: 'QUITTER',
    de: 'VERLASSEN',
    zh: '离开',
  );

  // ── Конец игры ────────────────────────────────────────────────────────────

  String get blackWins => _s(
    en: 'Black Wins!',
    ru: 'Победа чёрных!',
    he: '!השחור מנצח',
    es: '¡Gana el Negro!',
    fr: 'Les Noirs Gagnent !',
    de: 'Schwarz gewinnt!',
    zh: '黑棋获胜！',
  );

  String get whiteWins => _s(
    en: 'White Wins!',
    ru: 'Победа белых!',
    he: '!הלבן מנצח',
    es: '¡Gana el Blanco!',
    fr: 'Les Blancs Gagnent !',
    de: 'Weiß gewinnt!',
    zh: '白棋获胜！',
  );

  String get draw => _s(
    en: 'Draw!',
    ru: 'Ничья!',
    he: '!תיקו',
    es: '¡Empate!',
    fr: 'Match Nul !',
    de: 'Unentschieden!',
    zh: '平局！',
  );

  String get finalScore => _s(
    en: 'Final Score',
    ru: 'Итоговый счёт',
    he: 'תוצאה סופית',
    es: 'Puntuación Final',
    fr: 'Score Final',
    de: 'Endergebnis',
    zh: '最终得分',
  );

  String get menu => _s(
    en: 'MENU',
    ru: 'МЕНЮ',
    he: 'תפריט',
    es: 'MENÚ',
    fr: 'MENU',
    de: 'MENÜ',
    zh: '菜单',
  );

  String get playAgain => _s(
    en: 'PLAY AGAIN',
    ru: 'ИГРАТЬ СНОВА',
    he: 'שחק שוב',
    es: 'JUGAR DE NUEVO',
    fr: 'REJOUER',
    de: 'NOCHMAL SPIELEN',
    zh: '再玩一次',
  );

  // ── Настройки ─────────────────────────────────────────────────────────────

  String get settings => _s(
    en: 'SETTINGS',
    ru: 'НАСТРОЙКИ',
    he: 'הגדרות',
    es: 'AJUSTES',
    fr: 'PARAMÈTRES',
    de: 'EINSTELLUNGEN',
    zh: '设置',
  );

  String get soundSection => _s(
    en: 'Sound',
    ru: 'Звук',
    he: 'צליל',
    es: 'Sonido',
    fr: 'Son',
    de: 'Ton',
    zh: '声音',
  );

  String get gameSounds => _s(
    en: 'Game sounds',
    ru: 'Звуки игры',
    he: 'צלילי משחק',
    es: 'Sonidos del juego',
    fr: 'Sons du jeu',
    de: 'Spielgeräusche',
    zh: '游戏音效',
  );

  String get boardThemeSection => _s(
    en: 'Board Theme',
    ru: 'Тема доски',
    he: 'ערכת לוח',
    es: 'Tema del Tablero',
    fr: 'Thème du Plateau',
    de: 'Brett-Design',
    zh: '棋盘主题',
  );

  String get languageSection => _s(
    en: 'Language',
    ru: 'Язык',
    he: 'שפה',
    es: 'Idioma',
    fr: 'Langue',
    de: 'Sprache',
    zh: '语言',
  );

  // ── Правила ───────────────────────────────────────────────────────────────

  String get rulesTitle => _s(
    en: 'How to Play',
    ru: 'Как играть',
    he: 'כיצד לשחק',
    es: 'Cómo Jugar',
    fr: 'Comment Jouer',
    de: 'Spielregeln',
    zh: '游戏规则',
  );

  String get rulesText => _s(
    en:
    '1. Players take turns placing pieces\n\n'
        '2. Trap opponent\'s pieces between yours\n\n'
        '3. Trapped pieces flip to your color\n\n'
        '4. You must flip at least one piece per turn\n\n'
        '5. If you can\'t move, turn is skipped\n\n'
        '6. Most pieces at the end wins!',
    ru:
    '1. Игроки поочерёдно ставят фишки\n\n'
        '2. Окружите фишки соперника своими\n\n'
        '3. Захваченные фишки переворачиваются\n\n'
        '4. Каждый ход должен перевернуть хотя бы одну фишку\n\n'
        '5. Если ходов нет — ход пропускается\n\n'
        '6. Побеждает тот, у кого больше фишек!',
    he:
    '1. שחקנים מניחים כלים בתורות\n\n'
        '2. לכוד כלים של היריב בין הכלים שלך\n\n'
        '3. כלים שנלכדו הופכים לצבע שלך\n\n'
        '4. כל מהלך חייב להפוך לפחות כלי אחד\n\n'
        '5. אם אין מהלכים — מדלגים על התור\n\n'
        '6. מי שיש לו הכי הרבה כלים בסוף מנצח!',
    es:
    '1. Los jugadores colocan piezas por turnos\n\n'
        '2. Atrapa las piezas del oponente entre las tuyas\n\n'
        '3. Las piezas atrapadas cambian a tu color\n\n'
        '4. Debes voltear al menos una pieza por turno\n\n'
        '5. Si no puedes mover, se salta el turno\n\n'
        '6. ¡Quien tenga más piezas al final gana!',
    fr:
    '1. Les joueurs placent des pièces à tour de rôle\n\n'
        '2. Encadrez les pièces de l\'adversaire avec les vôtres\n\n'
        '3. Les pièces capturées changent de couleur\n\n'
        '4. Vous devez retourner au moins une pièce par tour\n\n'
        '5. Si vous ne pouvez pas jouer, le tour est sauté\n\n'
        '6. Le plus grand nombre de pièces à la fin gagne !',
    de:
    '1. Spieler setzen abwechselnd Steine\n\n'
        '2. Schließe gegnerische Steine zwischen deinen ein\n\n'
        '3. Eingeschlossene Steine werden umgedreht\n\n'
        '4. Pro Zug muss mindestens ein Stein umgedreht werden\n\n'
        '5. Wenn kein Zug möglich ist, wird der Zug übersprungen\n\n'
        '6. Wer am Ende die meisten Steine hat, gewinnt!',
    zh:
    '1. 双方轮流放置棋子\n\n'
        '2. 用己方棋子夹住对方棋子\n\n'
        '3. 被夹住的棋子翻转为己方颜色\n\n'
        '4. 每步必须至少翻转一枚棋子\n\n'
        '5. 若无法落子则跳过回合\n\n'
        '6. 最终棋子最多者获胜！',
  );

  String get gotIt => _s(
    en: 'GOT IT',
    ru: 'ПОНЯТНО',
    he: 'הבנתי',
    es: 'ENTENDIDO',
    fr: 'COMPRIS',
    de: 'VERSTANDEN',
    zh: '明白了',
  );

  // ── AD баннер ─────────────────────────────────────────────────────────────

  String get adPlaceholder => _s(
    en: 'AD BANNER PLACEHOLDER',
    ru: 'МЕСТО ДЛЯ РЕКЛАМЫ',
    he: 'מקום לפרסומת',
    es: 'ESPACIO PARA ANUNCIO',
    fr: 'ESPACE PUBLICITAIRE',
    de: 'WERBEBANNER-PLATZHALTER',
    zh: '广告横幅占位',
  );

  // ── Внутренний хелпер ─────────────────────────────────────────────────────

  String _s({
    required String en,
    required String ru,
    required String he,
    required String es,
    required String fr,
    required String de,
    required String zh,
  }) {
    switch (language) {
      case AppLanguage.english: return en;
      case AppLanguage.russian: return ru;
      case AppLanguage.hebrew:  return he;
      case AppLanguage.spanish: return es;
      case AppLanguage.french:  return fr;
      case AppLanguage.german:  return de;
      case AppLanguage.chinese: return zh;
    }
  }
}