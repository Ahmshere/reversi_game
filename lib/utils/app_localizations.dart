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

  String get hintTooltip => _s(
    en: 'Hint',
    ru: 'Подсказка',
    he: 'רמז',
    es: 'Pista',
    fr: 'Indice',
    de: 'Hinweis',
    zh: '提示',
  );

  String get undoTooltip => _s(
    en: 'Undo move',
    ru: 'Отменить ход',
    he: 'בטל מהלך',
    es: 'Deshacer jugada',
    fr: 'Annuler le coup',
    de: 'Zug rückgängig',
    zh: '悔棋',
  );

  // ── Диалог отмены хода (Undo за рекламу) ────────────────────────────────────

  String get undoDialogTitle => _s(
    en: 'Undo last move?',
    ru: 'Отменить последний ход?',
    he: 'לבטל את המהלך האחרון?',
    es: '¿Deshacer la última jugada?',
    fr: 'Annuler le dernier coup ?',
    de: 'Letzten Zug rückgängig machen?',
    zh: '要悔棋吗？',
  );

  String get undoDialogDesc => _s(
    en: 'Watch a short ad to take back your last move.',
    ru: 'Посмотрите короткую рекламу, чтобы отменить последний ход.',
    he: 'צפו בפרסומת קצרה כדי לבטל את המהלך האחרון שלכם.',
    es: 'Mira un anuncio corto para deshacer tu última jugada.',
    fr: 'Regardez une courte publicité pour annuler votre dernier coup.',
    de: 'Sieh dir eine kurze Werbung an, um deinen letzten Zug rückgängig zu machen.',
    zh: '观看一段短视频广告即可悔棋。',
  );

  String get watchAd => _s(
    en: 'WATCH AD',
    ru: 'СМОТРЕТЬ РЕКЛАМУ',
    he: 'צפייה בפרסומת',
    es: 'VER ANUNCIO',
    fr: 'VOIR LA PUB',
    de: 'WERBUNG ANSEHEN',
    zh: '观看广告',
  );

  String get adNotReady => _s(
    en: 'Ad not ready yet. Please try again in a moment.',
    ru: 'Реклама ещё не загрузилась. Попробуйте чуть позже.',
    he: 'הפרסומת עדיין לא מוכנה. נסו שוב בעוד רגע.',
    es: 'El anuncio aún no está listo. Inténtalo de nuevo en un momento.',
    fr: 'La publicité n\'est pas encore prête. Réessayez dans un instant.',
    de: 'Werbung ist noch nicht bereit. Bitte versuche es gleich noch einmal.',
    zh: '广告尚未准备好，请稍后重试。',
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

  String get aiDifficultySection => _s(
    en: 'AI Difficulty',
    ru: 'Сложность ИИ',
    he: 'רמת קושי המחשב',
    es: 'Dificultad de la IA',
    fr: 'Difficulté de l\'IA',
    de: 'KI-Schwierigkeit',
    zh: 'AI 难度',
  );

  String get difficultyEasy => _s(
    en: 'Easy',
    ru: 'Лёгкий',
    he: 'קל',
    es: 'Fácil',
    fr: 'Facile',
    de: 'Leicht',
    zh: '简单',
  );

  String get difficultyMedium => _s(
    en: 'Medium',
    ru: 'Средний',
    he: 'בינוני',
    es: 'Medio',
    fr: 'Moyen',
    de: 'Mittel',
    zh: '中等',
  );

  String get difficultyHard => _s(
    en: 'Hard',
    ru: 'Сложный',
    he: 'קשה',
    es: 'Difícil',
    fr: 'Difficile',
    de: 'Schwer',
    zh: '困难',
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

  // ── Chaos Mode ────────────────────────────────────────────────────────────

  String get chaosModeTitle => _s(
    en: 'CHAOS', ru: 'ХАОС', he: 'כאוס',
    es: 'CAOS', fr: 'CHAOS', de: 'CHAOS', zh: '混乱',
  );

  String get chaosModeSubtitle => _s(
    en: 'MODE', ru: 'РЕЖИМ', he: 'מצב',
    es: 'MODO', fr: 'MODE', de: 'MODUS', zh: '模式',
  );

  String get chaosModeDesc => _s(
    en: '🚫 Blocked cells · 💥 Explosive cells\n⭐ Bonus move · 🕳️ Collapsing floor',
    ru: '🚫 Заблокированные · 💥 Взрывные\n⭐ Бонусный ход · 🕳️ Проваливающийся пол',
    he: '🚫 חסומות · 💥 נפץ\n⭐ תור בונוס · 🕳️ רצפה קורסת',
    es: '🚫 Bloqueadas · 💥 Explosivas\n⭐ Turno extra · 🕳️ Suelo que cede',
    fr: '🚫 Bloquées · 💥 Explosives\n⭐ Tour bonus · 🕳️ Sol qui s\'effondre',
    de: '🚫 Blockiert · 💥 Explosiv\n⭐ Bonuszug · 🕳️ Einstürzender Boden',
    zh: '🚫 封闭格 · 💥 爆炸格\n⭐ 额外回合 · 🕳️ 塌陷地板',
  );

  // ── Модификатор-баннеры ───────────────────────────────────────────────────

  String get modifierExplosion => _s(
    en: '💥 Explosion! All neighbors flipped',
    ru: '💥 Взрыв! Все соседи перевёрнуты',
    he: '💥 פיצוץ! כל השכנים הפוכו',
    es: '💥 ¡Explosión! Vecinos volteados',
    fr: '💥 Explosion ! Voisins retournés',
    de: '💥 Explosion! Alle Nachbarn umgedreht',
    zh: '💥 爆炸！所有邻格翻转',
  );

  String get modifierBonus => _s(
    en: '⭐ Bonus! Extra turn granted',
    ru: '⭐ Бонус! Дополнительный ход',
    he: '⭐ בונוס! תור נוסף',
    es: '⭐ ¡Bono! Turno adicional',
    fr: '⭐ Bonus ! Tour supplémentaire',
    de: '⭐ Bonus! Zusätzlicher Zug',
    zh: '⭐ 奖励！获得额外回合',
  );

  String get modifierTrapdoor => _s(
    en: '🕳️ The floor collapsed!',
    ru: '🕳️ Пол провалился!',
    he: '🕳️ הרצפה קרסה!',
    es: '🕳️ ¡El suelo cedió!',
    fr: '🕳️ Le sol s\'est effondré !',
    de: '🕳️ Der Boden brach ein!',
    zh: '🕳️ 地板塌陷了！',
  );

  String get modifierLightning => _s(
    en: '⚡ Lightning strike! A piece was burned',
    ru: '⚡ Удар молнии! Фишка сгорела',
    he: '⚡ מכת ברק! חייל נשרף',
    es: '⚡ ¡Rayo! Una ficha se quemó',
    fr: '⚡ Foudre ! Un pion a brûlé',
    de: '⚡ Blitzeinschlag! Ein Stein ist verbrannt',
    zh: '⚡ 雷击！一枚棋子被烧毁',
  );

  String get aiThinking => _s(
    en: 'Computer is thinking…',
    ru: 'Компьютер думает…',
    he: 'המחשב חושב…',
    es: 'El ordenador piensa…',
    fr: 'L\'ordinateur réfléchit…',
    de: 'Computer überlegt…',
    zh: '电脑思考中…',
  );

  // ── Chaos Mode — правила ──────────────────────────────────────────────────

  String get chaosRulesTitle => _s(
    en: 'Chaos Mode Rules',
    ru: 'Правила режима Хаос',
    he: 'כללי מצב הכאוס',
    es: 'Reglas del modo Caos',
    fr: 'Règles du mode Chaos',
    de: 'Chaos-Modus Regeln',
    zh: '混乱模式规则',
  );

  String get chaosRulesIntro => _s(
    en: 'Classic Reversi rules apply, but special cells appear on the board every few moves:',
    ru: 'Действуют классические правила Реверси, но каждые несколько ходов на доске появляются особые клетки:',
    he: 'כללי ריברסי קלאסיים חלים, אך כל כמה מהלכים מופיעות תאים מיוחדים:',
    es: 'Aplican las reglas clásicas de Reversi, pero cada pocos turnos aparecen celdas especiales:',
    fr: 'Les règles classiques du Reversi s\'appliquent, mais des cases spéciales apparaissent toutes les quelques cases :',
    de: 'Klassische Reversi-Regeln gelten, aber alle paar Züge erscheinen besondere Felder:',
    zh: '适用经典黑白棋规则，但每隔几步会出现特殊格子：',
  );

  String get chaosRuleBlocked => _s(
    en: '🚫  Blocked — Cannot place a piece here. Also blocks capture lines passing through it.',
    ru: '🚫  Заблокировано — Нельзя ставить фишку. Также блокирует линии захвата через клетку.',
    he: '🚫  חסום — לא ניתן להניח כאן כלי. חוסם גם קווי לכידה.',
    es: '🚫  Bloqueada — No puedes colocar una ficha aquí. También bloquea las líneas de captura.',
    fr: '🚫  Bloquée — Impossible de poser une pièce ici. Bloque aussi les lignes de capture.',
    de: '🚫  Blockiert — Hier kann keine Figur gesetzt werden. Blockiert auch Capture-Linien.',
    zh: '🚫  封闭格 — 无法在此放子，同时阻断经过此格的翻转路线。',
  );

  String get chaosRuleExplosive => _s(
    en: '💥  Explosive — When you land here, ALL 8 surrounding pieces flip to your colour instantly.',
    ru: '💥  Взрывная — При постановке фишки ВСЕ 8 соседних фишек мгновенно переворачиваются в ваш цвет.',
    he: '💥  נפץ — כשמניחים כלי כאן, כל 8 הכלים השכנים הופכים לצבעך מיידית.',
    es: '💥  Explosiva — Al aterrizar aquí, las 8 piezas vecinas se voltean a tu color al instante.',
    fr: '💥  Explosive — En posant ici, les 8 pièces voisines passent instantanément à ta couleur.',
    de: '💥  Explosiv — Beim Setzen hier werden alle 8 Nachbarfiguren sofort zu deiner Farbe gedreht.',
    zh: '💥  爆炸格 — 落子后，周围8格的棋子瞬间全部翻转为你的颜色。',
  );

  String get chaosRuleBonus => _s(
    en: '⭐  Bonus — Landing here grants you an extra turn immediately.',
    ru: '⭐  Бонус — При постановке фишки вы получаете дополнительный ход.',
    he: '⭐  בונוס — נחיתה כאן מעניקה לך תור נוסף מיד.',
    es: '⭐  Bono — Aterrizar aquí te concede un turno extra de inmediato.',
    fr: '⭐  Bonus — Poser ici vous accorde immédiatement un tour supplémentaire.',
    de: '💫  Bonus — Das Setzen hier gewährt dir sofort einen zusätzlichen Zug.',
    zh: '⭐  奖励格 — 落子后立即获得一次额外回合。',
  );

  String get chaosRuleTrapdoor => _s(
    en: '🕳️  Collapsing floor — Every ~10 moves, a random occupied cell collapses: the piece disappears into the void.',
    ru: '🕳️  Проваливающийся пол — Каждые ~10 ходов случайная занятая клетка проваливается: фишка исчезает в бездну.',
    he: '🕳️  רצפה קורסת — כל ~10 מהלכים, תא תפוס אקראי קורס: הכלי נופל לתוך התהום.',
    es: '🕳️  Suelo que cede — Cada ~10 turnos, una celda ocupada aleatoria colapsa: la ficha desaparece en el vacío.',
    fr: '🕳️  Sol qui s\'effondre — Tous les ~10 coups, une case occupée s\'effondre : la pièce disparaît dans le vide.',
    de: '🕳️  Einstürzender Boden — Alle ~10 Züge bricht ein zufällig besetztes Feld ein: die Figur verschwindet im Nichts.',
    zh: '🕳️  塌陷地板 — 每约10步，一个随机有子格塌陷，棋子坠入虚空。',
  );

  String get chaosRuleSpawn => _s(
    en: 'New special cells appear every 6 moves (max 5 on board at once). Corners are always safe.',
    ru: 'Новые особые клетки появляются каждые 6 ходов (не более 5 на доске одновременно). Углы всегда безопасны.',
    he: 'תאים מיוחדים חדשים מופיעים כל 6 מהלכים (עד 5 בלוח בו-זמנית). הפינות תמיד בטוחות.',
    es: 'Nuevas celdas especiales aparecen cada 6 turnos (máx. 5 en el tablero a la vez). Las esquinas siempre son seguras.',
    fr: 'De nouvelles cases spéciales apparaissent tous les 6 coups (max. 5 sur le plateau à la fois). Les coins sont toujours sûrs.',
    de: 'Neue Sonderfelder erscheinen alle 6 Züge (max. 5 gleichzeitig auf dem Brett). Ecken sind immer sicher.',
    zh: '每6步出现新的特殊格（棋盘上最多同时5个）。角格永远安全。',
  );

  // ── Статистика ────────────────────────────────────────────────────────────

  String get statsTitle => _s(
    en: 'Statistics', ru: 'Статистика', he: 'סטטיסטיקה',
    es: 'Estadísticas', fr: 'Statistiques', de: 'Statistiken', zh: '统计',
  );
  String get statsClassic => _s(
    en: 'Classic', ru: 'Классика', he: 'קלאסי',
    es: 'Clásico', fr: 'Classique', de: 'Klassisch', zh: '经典',
  );
  String get statsChaos => _s(
    en: 'Chaos', ru: 'Хаос', he: 'כאוס',
    es: 'Caos', fr: 'Chaos', de: 'Chaos', zh: '混乱',
  );
  String get statsEmpty => _s(
    en: 'No games yet', ru: 'Игр пока нет', he: 'אין משחקים עדיין',
    es: 'Aún sin partidas', fr: 'Pas encore de parties', de: 'Noch keine Spiele', zh: '暂无记录',
  );
  String get statsGames => _s(
    en: 'Games', ru: 'Игр', he: 'משחקים',
    es: 'Partidas', fr: 'Parties', de: 'Spiele', zh: '场次',
  );
  String get statsWins => _s(
    en: 'Wins', ru: 'Побед', he: 'ניצחונות',
    es: 'Victorias', fr: 'Victoires', de: 'Siege', zh: '胜',
  );
  String get statsLosses => _s(
    en: 'Losses', ru: 'Поражений', he: 'הפסדים',
    es: 'Derrotas', fr: 'Défaites', de: 'Niederlagen', zh: '负',
  );
  String get statsDraws => _s(
    en: 'Draws', ru: 'Ничьих', he: 'תיקו',
    es: 'Empates', fr: 'Nulles', de: 'Unentschieden', zh: '平',
  );
  String get statsAvgMoves => _s(
    en: 'Avg\nmoves', ru: 'Ср.\nходов', he: 'מהל׳\nממוצע',
    es: 'Mov.\npromedio', fr: 'Coups\nmoy.', de: 'Ø\nZüge', zh: '平均\n步数',
  );
  String get statsMoves => _s(
    en: 'Moves', ru: 'Ходов', he: 'מהלכים',
    es: 'Movimientos', fr: 'Coups', de: 'Züge', zh: '步数',
  );
  String get statsTrapdoors => _s(
    en: 'Trapdoors', ru: 'Провалов', he: 'מלכודות',
    es: 'Trampillas', fr: 'Trapdoors', de: 'Falltüren', zh: '陷阱',
  );
  String get statsExplosions => _s(
    en: 'Explosions', ru: 'Взрывов', he: 'פיצוצים',
    es: 'Explosiones', fr: 'Explosions', de: 'Explosionen', zh: '爆炸',
  );
  String get statsClear => _s(
    en: 'Clear history', ru: 'Очистить историю', he: 'נקה היסטוריה',
    es: 'Borrar historial', fr: 'Effacer l\'historique', de: 'Verlauf löschen', zh: '清除历史',
  );
  String get statsClearTitle => _s(
    en: 'Clear statistics?', ru: 'Очистить статистику?', he: 'לנקות סטטיסטיקה?',
    es: '¿Borrar estadísticas?', fr: 'Effacer les statistiques?', de: 'Statistiken löschen?', zh: '清除统计？',
  );
  String get statsClearConfirm => _s(
    en: 'All game history will be deleted.', ru: 'Вся история игр будет удалена.',
    he: 'כל היסטוריית המשחקים תימחק.', es: 'Se eliminará todo el historial.',
    fr: 'Tout l\'historique sera supprimé.', de: 'Gesamter Verlauf wird gelöscht.', zh: '所有游戏记录将被删除。',
  );

  // ── Достижения ────────────────────────────────────────────────────────────

  String get achievementsTitle => _s(
    en: 'Achievements', ru: 'Достижения', he: 'הישגים',
    es: 'Logros', fr: 'Succès', de: 'Erfolge', zh: '成就',
  );

  String achievementsProgress(int unlocked, int total) => _s(
    en: '$unlocked / $total unlocked',
    ru: '$unlocked / $total открыто',
    he: '$unlocked מתוך $total נפתחו',
    es: '$unlocked / $total desbloqueados',
    fr: '$unlocked / $total débloqués',
    de: '$unlocked / $total freigeschaltet',
    zh: '已解锁 $unlocked / $total',
  );

  String get achievementLocked => _s(
    en: 'Locked', ru: 'Заблокировано', he: 'נעול',
    es: 'Bloqueado', fr: 'Verrouillé', de: 'Gesperrt', zh: '未解锁',
  );

  String get newAchievementBanner => _s(
    en: '🏆 New Achievement!',
    ru: '🏆 Новое достижение!',
    he: '🏆 הישג חדש!',
    es: '🏆 ¡Nuevo logro!',
    fr: '🏆 Nouveau succès !',
    de: '🏆 Neuer Erfolg!',
    zh: '🏆 解锁新成就！',
  );

  String get achFirstGameTitle => _s(
    en: 'First Steps', ru: 'Первые шаги', he: 'צעדים ראשונים',
    es: 'Primeros Pasos', fr: 'Premiers Pas', de: 'Erste Schritte', zh: '第一步',
  );
  String get achFirstGameDesc => _s(
    en: 'Play your first game',
    ru: 'Сыграйте первую партию',
    he: 'שחקו את המשחק הראשון שלכם',
    es: 'Juega tu primera partida',
    fr: 'Jouez votre première partie',
    de: 'Spiele dein erstes Spiel',
    zh: '完成你的第一局游戏',
  );

  String get achGames10Title => _s(
    en: 'Regular', ru: 'Завсегдатай', he: 'קבוע',
    es: 'Habitual', fr: 'Habitué', de: 'Stammspieler', zh: '常客',
  );
  String get achGames10Desc => _s(
    en: 'Play 10 games',
    ru: 'Сыграйте 10 партий',
    he: 'שחקו 10 משחקים',
    es: 'Juega 10 partidas',
    fr: 'Jouez 10 parties',
    de: 'Spiele 10 Spiele',
    zh: '完成10局游戏',
  );

  String get achGames50Title => _s(
    en: 'Veteran', ru: 'Ветеран', he: 'ותיק',
    es: 'Veterano', fr: 'Vétéran', de: 'Veteran', zh: '资深玩家',
  );
  String get achGames50Desc => _s(
    en: 'Play 50 games',
    ru: 'Сыграйте 50 партий',
    he: 'שחקו 50 משחקים',
    es: 'Juega 50 partidas',
    fr: 'Jouez 50 parties',
    de: 'Spiele 50 Spiele',
    zh: '完成50局游戏',
  );

  String get achFirstWinTitle => _s(
    en: 'First Victory', ru: 'Первая победа', he: 'ניצחון ראשון',
    es: 'Primera Victoria', fr: 'Première Victoire', de: 'Erster Sieg', zh: '首次胜利',
  );
  String get achFirstWinDesc => _s(
    en: 'Win your first game',
    ru: 'Одержите первую победу',
    he: 'נצחו במשחק הראשון שלכם',
    es: 'Gana tu primera partida',
    fr: 'Gagnez votre première partie',
    de: 'Gewinne dein erstes Spiel',
    zh: '赢得你的第一场胜利',
  );

  String get achStreak3Title => _s(
    en: 'Win Streak', ru: 'Победная серия', he: 'רצף ניצחונות',
    es: 'Racha Ganadora', fr: 'Série de Victoires', de: 'Siegesserie', zh: '连胜',
  );
  String get achStreak3Desc => _s(
    en: 'Win 3 games in a row',
    ru: '3 победы подряд',
    he: 'נצחו 3 משחקים ברצף',
    es: 'Gana 3 partidas seguidas',
    fr: 'Gagnez 3 parties d\'affilée',
    de: 'Gewinne 3 Spiele in Folge',
    zh: '连续赢得3局',
  );

  String get achStreak5Title => _s(
    en: 'Unstoppable', ru: 'Не остановить', he: 'בלתי ניתן לעצירה',
    es: 'Imparable', fr: 'Imparable', de: 'Unaufhaltsam', zh: '势不可挡',
  );
  String get achStreak5Desc => _s(
    en: 'Win 5 games in a row',
    ru: '5 побед подряд',
    he: 'נצחו 5 משחקים ברצף',
    es: 'Gana 5 partidas seguidas',
    fr: 'Gagnez 5 parties d\'affilée',
    de: 'Gewinne 5 Spiele in Folge',
    zh: '连续赢得5局',
  );

  String get achDominationTitle => _s(
    en: 'Domination', ru: 'Разгром', he: 'שליטה מוחלטת',
    es: 'Dominación', fr: 'Domination', de: 'Dominanz', zh: '碾压',
  );
  String get achDominationDesc => _s(
    en: 'Win by a margin of 40+ pieces',
    ru: 'Победите с разницей 40+ фишек',
    he: 'נצחו בהפרש של 40+ כלים',
    es: 'Gana con una ventaja de 40+ piezas',
    fr: 'Gagnez avec un écart de 40+ pièces',
    de: 'Gewinne mit einem Vorsprung von 40+ Steinen',
    zh: '以40+枚棋子的优势获胜',
  );

  String get achSpeedrunTitle => _s(
    en: 'Blitz', ru: 'Блицкриг', he: 'בזק',
    es: 'Blitz', fr: 'Blitz', de: 'Blitz', zh: '闪电战',
  );
  String get achSpeedrunDesc => _s(
    en: 'Win a game in 22 moves or fewer',
    ru: 'Победите за 22 хода или меньше',
    he: 'נצחו במשחק תוך 22 מהלכים או פחות',
    es: 'Gana una partida en 22 movimientos o menos',
    fr: 'Gagnez une partie en 22 coups ou moins',
    de: 'Gewinne ein Spiel in 22 Zügen oder weniger',
    zh: '在22步以内获胜',
  );

  String get achBoomTitle => _s(
    en: 'Boom!', ru: 'Бум!', he: 'בום!',
    es: '¡Bum!', fr: 'Boum !', de: 'Bumm!', zh: '轰！',
  );
  String get achBoomDesc => _s(
    en: 'Trigger an explosive cell in Chaos Mode',
    ru: 'Активируйте взрывную клетку в Chaos Mode',
    he: 'הפעילו תא נפץ במצב הכאוס',
    es: 'Activa una celda explosiva en el modo Caos',
    fr: 'Déclenchez une case explosive en mode Chaos',
    de: 'Löse ein Explosionsfeld im Chaos-Modus aus',
    zh: '在混乱模式中触发一个爆炸格',
  );

  String get achChainReactionTitle => _s(
    en: 'Chain Reaction', ru: 'Цепная реакция', he: 'תגובת שרשרת',
    es: 'Reacción en Cadena', fr: 'Réaction en Chaîne', de: 'Kettenreaktion', zh: '连锁反应',
  );
  String get achChainReactionDesc => _s(
    en: 'Flip 15+ pieces with explosions in one game',
    ru: 'Переверните взрывами 15+ фишек за одну партию',
    he: 'הפכו 15+ כלים בעזרת פיצוצים במשחק אחד',
    es: 'Voltea 15+ piezas con explosiones en una partida',
    fr: 'Retournez 15+ pièces avec des explosions en une partie',
    de: 'Drehe 15+ Steine durch Explosionen in einem Spiel um',
    zh: '在一局游戏中通过爆炸翻转15枚以上棋子',
  );

  String get achTrapdoorTitle => _s(
    en: 'Into the Void', ru: 'В бездну', he: 'אל התהום',
    es: 'Al Vacío', fr: 'Dans le Vide', de: 'Ins Nichts', zh: '坠入虚空',
  );
  String get achTrapdoorDesc => _s(
    en: 'Trigger a collapsing floor in Chaos Mode',
    ru: 'Активируйте проваливающийся пол в Chaos Mode',
    he: 'הפעילו רצפה קורסת במצב הכאוס',
    es: 'Activa un suelo que cede en el modo Caos',
    fr: 'Déclenchez un sol qui s\'effondre en mode Chaos',
    de: 'Löse einen einstürzenden Boden im Chaos-Modus aus',
    zh: '在混乱模式中触发塌陷地板',
  );

  String get achChaosMasterTitle => _s(
    en: 'Chaos Master', ru: 'Повелитель хаоса', he: 'אדון הכאוס',
    es: 'Maestro del Caos', fr: 'Maître du Chaos', de: 'Chaos-Meister', zh: '混乱大师',
  );
  String get achChaosMasterDesc => _s(
    en: 'Win 10 games in Chaos Mode',
    ru: 'Выиграйте 10 партий в Chaos Mode',
    he: 'נצחו 10 משחקים במצב הכאוס',
    es: 'Gana 10 partidas en el modo Caos',
    fr: 'Gagnez 10 parties en mode Chaos',
    de: 'Gewinne 10 Spiele im Chaos-Modus',
    zh: '在混乱模式中赢得10局游戏',
  );

  String get achGiantSlayerTitle => _s(
    en: 'Giant Slayer', ru: 'Победитель гигантов', he: 'הורג הענקים',
    es: 'Matagigantes', fr: 'Tueur de Géants', de: 'Riesentöter', zh: '屠巨者',
  );
  String get achGiantSlayerDesc => _s(
    en: 'Beat the AI on Hard difficulty',
    ru: 'Обыграйте ИИ на сложности Hard',
    he: 'נצחו את המחשב ברמת קושי קשה',
    es: 'Vence a la IA en dificultad Difícil',
    fr: 'Battez l\'IA en difficulté Difficile',
    de: 'Besiege die KI auf Schwer',
    zh: '在困难难度下击败AI',
  );

  // ── Туториал — навигация ──────────────────────────────────────────────────

  String get tutBack => _s(en:'Back', ru:'Назад', he:'חזרה', es:'Atrás', fr:'Retour', de:'Zurück', zh:'上一步');
  String get tutNext => _s(en:'Next', ru:'Далее', he:'הבא', es:'Siguiente', fr:'Suivant', de:'Weiter', zh:'下一步');
  String get tutDone => _s(en:'Done', ru:'Готово', he:'סיום', es:'Listo', fr:'Terminé', de:'Fertig', zh:'完成');

  // ── Туториал — шаги ───────────────────────────────────────────────────────

  String get tutStep1Title => _s(
    en: 'The board and starting position',
    ru: 'Доска и начальная позиция',
    he: 'הלוח ומיקום ההתחלה',
    es: 'El tablero y posición inicial',
    fr: 'Le plateau et la position de départ',
    de: 'Das Brett und die Startposition',
    zh: '棋盘和起始位置',
  );
  String get tutStep1Desc => _s(
    en: 'Reversi is played on an 8×8 grid. The game starts with 4 pieces in the centre — 2 black and 2 white arranged diagonally.',
    ru: 'Реверси играется на доске 8×8. Игра начинается с 4 фишек в центре — 2 чёрных и 2 белых, расположенных по диагонали.',
    he: 'רברסי משחקים על לוח 8×8. המשחק מתחיל עם 4 כלים במרכז — 2 שחורים ו-2 לבנים בסידור אלכסוני.',
    es: 'Reversi se juega en una cuadrícula de 8×8. El juego comienza con 4 piezas en el centro — 2 negras y 2 blancas en diagonal.',
    fr: 'Reversi se joue sur une grille 8×8. Le jeu commence avec 4 pièces au centre — 2 noires et 2 blanches en diagonale.',
    de: 'Reversi wird auf einem 8×8-Raster gespielt. Das Spiel beginnt mit 4 Steinen in der Mitte — 2 schwarze und 2 weiße diagonal angeordnet.',
    zh: '黑白棋在8×8的棋盘上进行。游戏从中央4枚棋子开始——2枚黑棋和2枚白棋对角排列。',
  );

  String get tutStep2Title => _s(
    en: 'Valid moves — sandwich the opponent',
    ru: 'Допустимые ходы — окружите соперника',
    he: 'מהלכים חוקיים — לכוד את היריב',
    es: 'Movimientos válidos — sándwich al oponente',
    fr: 'Mouvements valides — encerclez l\'adversaire',
    de: 'Gültige Züge — den Gegner einschließen',
    zh: '合法走法——夹住对手',
  );
  String get tutStep2Desc => _s(
    en: 'Black goes first. Yellow dots are valid moves. Each one sandwiches at least one white piece in a straight line between the new black piece and an existing black piece.',
    ru: 'Чёрные ходят первыми. Жёлтые точки — допустимые ходы. Каждая клетка зажимает хотя бы одну белую фишку по прямой между новой чёрной и уже стоящей чёрной.',
    he: 'השחור הולך ראשון. נקודות צהובות הן מהלכים חוקיים. כל אחד לוכד לפחות כלי לבן אחד בקו ישר בין כלי שחור חדש לקיים.',
    es: 'Las negras van primero. Los puntos amarillos son movimientos válidos. Cada uno atrapa al menos una pieza blanca en línea recta entre la nueva negra y una existente.',
    fr: 'Les noirs jouent en premier. Les points jaunes sont des coups valides. Chacun piège au moins une pièce blanche en ligne droite entre la nouvelle noire et une existante.',
    de: 'Schwarz ist zuerst dran. Gelbe Punkte sind gültige Züge. Jeder schließt mindestens einen weißen Stein in gerader Linie zwischen dem neuen und einem bestehenden schwarzen ein.',
    zh: '黑棋先走。黄色圆点是合法走法。每步在直线上将至少一枚白棋夹在新黑棋和已有黑棋之间。',
  );

  String get tutStep3Title => _s(
    en: 'Place a piece — the white one flips!',
    ru: 'Ставим фишку — белая переворачивается!',
    he: 'מניחים כלי — הלבן מתהפך!',
    es: '¡Colocar una pieza — la blanca se voltea!',
    fr: 'Placer une pièce — la blanche se retourne !',
    de: 'Stein setzen — der weiße wird umgedreht!',
    zh: '落子——白棋被翻转！',
  );
  String get tutStep3Desc => _s(
    en: 'Black plays at the highlighted cell. The white piece between the two black pieces is now sandwiched — it flips to black! The red arrow shows the direction of capture.',
    ru: 'Чёрные играют в подсвеченную клетку. Белая фишка оказывается между двух чёрных и переворачивается! Красная стрелка показывает направление захвата.',
    he: 'השחור משחק בתא המודגש. הכלי הלבן שנמצא בין שני הכלים השחורים נלכד — הוא מתהפך לשחור! החץ האדום מציג את כיוון הלכידה.',
    es: 'Las negras juegan en la celda resaltada. La pieza blanca entre las dos negras queda atrapada — ¡se voltea a negro! La flecha roja muestra la dirección de captura.',
    fr: 'Les noirs jouent dans la case surlignée. La pièce blanche entre les deux noires est prise en sandwich — elle se retourne en noire ! La flèche rouge montre la direction de capture.',
    de: 'Schwarz spielt in das markierte Feld. Der weiße Stein zwischen den beiden schwarzen ist eingeschlossen — er wird zu schwarz! Der rote Pfeil zeigt die Richtung der Aufnahme.',
    zh: '黑棋落在高亮格子。两枚黑棋之间的白棋被夹住——翻转为黑棋！红色箭头显示捕获方向。',
  );

  String get tutStep4Title => _s(
    en: 'After the flip — white\'s turn',
    ru: 'После переворота — ход белых',
    he: 'אחרי ההיפוך — תור הלבן',
    es: 'Después del volteo — turno de blancas',
    fr: 'Après le retournement — au tour des blancs',
    de: 'Nach dem Umdrehen — Weiß ist dran',
    zh: '翻转后——轮到白棋',
  );
  String get tutStep4Desc => _s(
    en: 'Black now has 4 pieces, white has 1. It\'s white\'s turn — white must also make a move that sandwiches at least one black piece. The game alternates until no moves remain.',
    ru: 'Теперь у чёрных 4 фишки, у белых 1. Ход белых — нужно тоже окружить хотя бы одну чёрную фишку. Игра продолжается поочерёдно, пока у кого-то есть ходы.',
    he: 'לשחור יש כעת 4 כלים, ללבן יש 1. תור הלבן — הלבן גם צריך לבצע מהלך שלוכד לפחות כלי שחור אחד. המשחק מתחלף עד שאין מהלכים.',
    es: 'Las negras tienen ahora 4 piezas, las blancas 1. Es el turno de las blancas — también deben hacer un movimiento que atrape al menos una negra. El juego alterna hasta que no quedan movimientos.',
    fr: 'Les noirs ont maintenant 4 pièces, les blancs 1. C\'est au tour des blancs — ils doivent aussi faire un mouvement qui piège au moins une noire. Le jeu alterne jusqu\'à ce qu\'il n\'y ait plus de coups.',
    de: 'Schwarz hat jetzt 4 Steine, Weiß hat 1. Weiß ist dran — Weiß muss auch einen Zug machen, der mindestens einen schwarzen Stein einschließt. Das Spiel wechselt ab, bis keine Züge mehr übrig sind.',
    zh: '黑棋现在有4枚，白棋有1枚。轮到白棋——白棋也必须走一步夹住至少一枚黑棋。双方交替直到无法走棋为止。',
  );

  String get tutStep5Title => _s(
    en: 'Result: 4 black, 1 white — white moves next',
    ru: 'Итог: 4 чёрных, 1 белая — ход белых',
    he: 'תוצאה: 4 שחורים, 1 לבן — תור הלבן',
    es: 'Resultado: 4 negras, 1 blanca — mueven las blancas',
    fr: 'Résultat : 4 noires, 1 blanche — les blancs jouent',
    de: 'Ergebnis: 4 schwarz, 1 weiß — Weiß ist dran',
    zh: '结果：4黑1白——轮到白棋',
  );
  String get tutStep5Desc => _s(
    en: 'The flipped piece glows — it changed from white to black. Black now has 4 pieces, white has only 1. Now white must find a move that sandwiches at least one black piece.',
    ru: 'Перевёрнутая фишка подсвечена — она стала чёрной. У чёрных теперь 4 фишки, у белых всего 1. Теперь белые должны найти ход, который окружит хотя бы одну чёрную.',
    he: 'הכלי שהופך מוארגן — הוא הפך משחור ללבן. לשחור יש עכשיו 4 כלים, ללבן רק 1. עכשיו הלבן חייב למצוא מהלך שלוכד לפחות כלי שחור אחד.',
    es: 'La pieza volteada brilla — cambió de blanca a negra. Las negras tienen ahora 4 piezas, las blancas solo 1. Ahora las blancas deben encontrar un movimiento que capture al menos una negra.',
    fr: 'La pièce retournée brille — elle est passée de blanche à noire. Les noirs ont maintenant 4 pièces, les blancs seulement 1. Maintenant les blancs doivent trouver un coup qui capture au moins une noire.',
    de: 'Der umgedrehte Stein leuchtet — er wechselte von weiß zu schwarz. Schwarz hat jetzt 4 Steine, Weiß nur 1. Jetzt muss Weiß einen Zug finden, der mindestens einen schwarzen Stein einschließt.',
    zh: '翻转的棋子发光——它从白变成了黑。黑棋现在有4枚，白棋只有1枚。现在白棋必须找到一步能夹住至少一枚黑棋的走法。',
  );

  String get tutStep6Title => _s(
    en: 'Diagonal capture works too',
    ru: 'Диагональный захват тоже работает',
    he: 'לכידה אלכסונית עובדת גם',
    es: 'La captura diagonal también funciona',
    fr: 'La capture diagonale fonctionne aussi',
    de: 'Diagonale Einnahme funktioniert auch',
    zh: '斜线方向同样可以夹子',
  );
  String get tutStep6Desc => _s(
    en: 'Capturing works in all 8 directions — horizontal, vertical, and diagonal. Here we place a black piece top-left. The existing black piece bottom-right is the anchor — 2 white pieces between them are captured diagonally.',
    ru: 'Захват работает во всех 8 направлениях — по горизонтали, вертикали и диагонали. Ставим чёрную фишку слева вверху. Якорная чёрная — справа внизу. 2 белых между ними захватываются по диагонали.',
    he: 'לכידה עובדת בכל 8 הכיוונים. מניחים כלי שחור בפינה שמאל-למעלה. הכלי השחור העוגן נמצא ימין-למטה. 2 לבנים ביניהם נלכדים אלכסונית.',
    es: 'La captura funciona en las 8 direcciones. Colocamos una negra arriba-izquierda. La negra ancla está abajo-derecha. 2 blancas entre ellas son capturadas diagonalmente.',
    fr: 'La capture fonctionne dans les 8 directions. On place une noire en haut-gauche. La noire ancre est en bas-droite. 2 blanches entre elles sont capturées en diagonale.',
    de: 'Einnahmen funktionieren in allen 8 Richtungen. Wir setzen einen schwarzen Stein oben-links. Der schwarze Ankerpool ist unten-rechts. 2 weiße Steine dazwischen werden diagonal eingenommen.',
    zh: '夹子在所有8个方向都有效。我们将黑棋放在左上角。右下角是己方锚棋。两者之间的2枚白棋被斜向夹住。',
  );

  String get tutStep7Title => _s(
    en: 'Corners are gold — most pieces wins!',
    ru: 'Углы — на вес золота! Побеждает тот, у кого больше.',
    he: 'הפינות הן זהב — המנצח הוא בעל הכלים הרבים!',
    es: '¡Las esquinas son oro — gana quien tenga más piezas!',
    fr: 'Les coins valent de l\'or — le plus de pièces gagne !',
    de: 'Ecken sind Gold — wer die meisten Steine hat, gewinnt!',
    zh: '角落是黄金——棋子最多者获胜！',
  );
  String get tutStep7Desc => _s(
    en: 'The 4 corner squares (★) can never be flipped once taken — the most valuable spots on the board. When neither player can move, count pieces. Most pieces wins!',
    ru: 'Четыре угла (★) нельзя перевернуть — самые ценные клетки. Когда ни у кого нет ходов — считаем фишки. Больше фишек — победа!',
    he: '4 הפינות (★) לא ניתן להפוך לאחר שנתפסו — הריבועים הכי יקרים. כשאף שחקן לא יכול לזוז, סופרים כלים. הכי הרבה — מנצח!',
    es: 'Las 4 esquinas (★) nunca pueden voltearse una vez capturadas — los lugares más valiosos. Cuando nadie puede moverse, cuenta piezas. ¡Más piezas gana!',
    fr: 'Les 4 coins (★) ne peuvent jamais être retournés — les cases les plus précieuses. Quand personne ne peut jouer, comptez. Le plus de pièces gagne !',
    de: 'Die 4 Ecken (★) können nie umgedreht werden — die wertvollsten Felder. Wenn niemand mehr ziehen kann, zählen wir. Die meisten Steine gewinnen!',
    zh: '4个角落（★）一旦占据永远无法被翻转——最有价值的位置。双方都无法走棋时数棋子，最多者获胜！',
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