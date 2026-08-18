import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../engine/game_engine.dart';
import 'player_state.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TABLE PLAYER — real player at a seat (human or bot)
// ═══════════════════════════════════════════════════════════════════════════
class TableSeat {
  final String seatId;        // seat label: 'S1'...'S5'
  final bool isYou;
  final bool isBot;
  final bool isEmpty;

  // Real mutable fields
  String name;
  int chips;
  int currentBet;
  SpotType? placedSide;       // which side they bet (AB)
  bool isOnline;
  bool isTurn;
  String avatarEmoji;         // no images — real text avatars

  TableSeat({
    required this.seatId,
    required this.name,
    required this.chips,
    this.isYou  = false,
    this.isBot  = false,
    this.isEmpty = false,
    this.currentBet = 0,
    this.placedSide,
    this.isOnline = true,
    this.isTurn   = false,
    this.avatarEmoji = '👤',
  });

  factory TableSeat.empty(String seatId) => TableSeat(
    seatId: seatId, name: '', chips: 0, isEmpty: true, avatarEmoji: '➕',
  );

  factory TableSeat.bot(String seatId, String name, int chips) => TableSeat(
    seatId: seatId, name: name, chips: chips,
    isBot: true, avatarEmoji: _botEmoji(name),
  );

  static String _botEmoji(String name) {
    const emojis = ['🎩','🕵','🤵','👑','🎭','🦊','🐯','🦁'];
    return emojis[name.hashCode.abs() % emojis.length];
  }

  String get formattedChips {
    if (chips >= 100000) return '${(chips / 100000).toStringAsFixed(1)}L';
    if (chips >= 1000)   return '${chips ~/ 1000}K';
    return '$chips';
  }

  TableSeat copyWith({
    String? name, int? chips, int? currentBet,
    SpotType? placedSide, bool? isOnline, bool? isTurn,
  }) => TableSeat(
    seatId: seatId, name: name ?? this.name, chips: chips ?? this.chips,
    isYou: isYou, isBot: isBot, isEmpty: false,
    currentBet: currentBet ?? this.currentBet,
    placedSide: placedSide ?? this.placedSide,
    isOnline: isOnline ?? this.isOnline,
    isTurn: isTurn ?? this.isTurn,
    avatarEmoji: avatarEmoji,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAT MESSAGE
// ═══════════════════════════════════════════════════════════════════════════
class ChatMessage {
  final String sender;
  final String text;
  final bool isSystem;
  final DateTime time;

  ChatMessage({required this.sender, required this.text, this.isSystem = false})
      : time = DateTime.now();
}

// ═══════════════════════════════════════════════════════════════════════════
// ANDAR BAHAR GAME STATE — real engine, real chips, real players
// ═══════════════════════════════════════════════════════════════════════════
enum ABGamePhase { waiting, betting, dealing, roundResult }

class AndarBaharGameState extends ChangeNotifier {
  final PlayerState playerState;
  final Random _rng = Random.secure();

  // ── Seats ─────────────────────────────────────────────────────────────────
  late List<TableSeat> seats;

  // ── Andar Bahar specific state (from engine) ──────────────────────────────
  Card? jokerCard;
  List<Card> andarCards = [];
  List<Card> baharCards = [];
  ABGamePhase phase = ABGamePhase.waiting;
  SpotType? winningSpot;
  SpotType? yourSide;          // real player's chosen side
  int yourBet = 0;
  int yourTotalWon = 0;
  int roundNumber = 0;
  bool autoRebet = false;
  int lastBetAmount = 200;

  // Pools — sum of all bets at table
  int andarPool = 0;
  int baharPool = 0;

  // ── Chat ──────────────────────────────────────────────────────────────────
  final List<ChatMessage> chatMessages = [];

  // ── Deal animation queue ──────────────────────────────────────────────────
  List<AndarBaharStep> _pendingSteps = [];
  int _stepIndex = 0;
  Timer? _dealTimer;

  // ── Bot timer ─────────────────────────────────────────────────────────────
  Timer? _botTimer;
  Timer? _bettingTimer;
  int bettingSecondsLeft = 15;

  AndarBaharGameState({required this.playerState}) {
    _initSeats();
    _startNewRound();
  }

  // ── Initialize 5 seats: YOU + 4 bots ────────────────────────────────────
  void _initSeats() {
    seats = [
      TableSeat(seatId: 'S1', name: 'Fahad', chips: 32000,   isBot: true,  avatarEmoji: '🎩'),
      TableSeat(seatId: 'S2', name: 'Bahar', chips: 2000,    isBot: true,  avatarEmoji: '🕵'),
      TableSeat(seatId: 'S3',
        name: playerState.name.isEmpty ? 'You' : playerState.name,
        chips: playerState.chips,
        isYou: true,
        avatarEmoji: '👑',
      ),
      TableSeat.empty('S4'),
      TableSeat(seatId: 'S5', name: 'HODAYATSOP', chips: 32000, isBot: true, avatarEmoji: '🦊'),
    ];
    _addChat('System', '🎲 New table started — Table #${100 + _rng.nextInt(900)}', isSystem: true);
  }

  // ── Sync player chips from PlayerState ────────────────────────────────────
  void _syncPlayerChips() {
    final yourIndex = seats.indexWhere((s) => s.isYou);
    if (yourIndex >= 0) {
      seats[yourIndex] = seats[yourIndex].copyWith(chips: playerState.chips);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITE — real player can invite friend to empty seat
  // ═══════════════════════════════════════════════════════════════════════════
  void inviteToSeat(String seatId, {String? friendName}) {
    final index = seats.indexWhere((s) => s.seatId == seatId);
    if (index < 0 || !seats[index].isEmpty) return;

    // Simulate invited player joining (in real app: send WebSocket invite)
    final invitedName = friendName ?? 'Guest_${_rng.nextInt(9999)}';
    seats[index] = TableSeat(
      seatId: seatId,
      name: invitedName,
      chips: 5000 + _rng.nextInt(45000),
      isBot: friendName == null, // if no real friend: bot fills seat
      avatarEmoji: '🤝',
    );
    _addChat('System', '✅ $invitedName joined seat $seatId', isSystem: true);
    notifyListeners();
  }

  // ─── Remove player from seat ──────────────────────────────────────────────
  void leaveTable(String seatId) {
    final index = seats.indexWhere((s) => s.seatId == seatId);
    if (index < 0) return;
    final name = seats[index].name;
    seats[index] = TableSeat.empty(seatId);
    _addChat('System', '👋 $name left the table', isSystem: true);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUND FLOW
  // ═══════════════════════════════════════════════════════════════════════════
  void _startNewRound() {
    roundNumber++;
    andarCards   = [];
    baharCards   = [];
    jokerCard    = null;
    winningSpot  = null;
    yourSide     = null;
    yourBet      = 0;
    andarPool    = 0;
    baharPool    = 0;
    phase        = ABGamePhase.betting;
    bettingSecondsLeft = 15;

    // Reset seat bets
    for (int i = 0; i < seats.length; i++) {
      if (!seats[i].isEmpty) {
        seats[i] = seats[i].copyWith(currentBet: 0, placedSide: null);
      }
    }

    // Auto-rebet
    if (autoRebet && lastBetAmount > 0 && yourSide != null) {
      placeBet(yourSide!, lastBetAmount);
    }

    // Bot betting timer
    _bettingTimer?.cancel();
    _bettingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!t.isActive) return;
      bettingSecondsLeft--;
      if (bettingSecondsLeft <= 0) {
        t.cancel();
        _botsPlaceBets();
        if (yourSide != null) _executeDeal();
        notifyListeners();
      }
      notifyListeners();
    });

    // Bots place bets randomly after 1-4s
    _botTimer = Timer(Duration(seconds: 1 + _rng.nextInt(3)), _botsPlaceBets);

    notifyListeners();
  }

  // ── PLAYER places bet on Andar or Bahar ────────────────────────────────────
  /// Returns error string or null on success
  String? placeBet(SpotType side, int amount) {
    if (phase != ABGamePhase.betting) return 'Betting phase is over';
    if (amount <= 0)                   return 'Bet must be > 0';
    if (amount > playerState.chips)    return 'Insufficient chips';

    // Deduct from real wallet
    final success = playerState.placeBet(amount);
    if (!success) return 'Insufficient chips';

    yourSide = side;
    yourBet  = amount;
    lastBetAmount = amount;

    // Update pool
    if (side == SpotType.andar) andarPool += amount;
    else                        baharPool += amount;

    _syncPlayerChips();

    _addChat('You', '🎯 Placed ₹${_fmt(amount)} on ${side == SpotType.andar ? "Andar" : "Bahar"}');
    notifyListeners();
    return null; // success
  }

  // ── Change bet (before deal) ──────────────────────────────────────────────
  void changeSide(SpotType side) {
    if (phase != ABGamePhase.betting) return;
    yourSide = side;
    notifyListeners();
  }

  // ── DEAL button pressed ────────────────────────────────────────────────────
  void deal() {
    if (phase == ABGamePhase.dealing || phase == ABGamePhase.roundResult) return;
    _bettingTimer?.cancel();
    _botsPlaceBets();
    _executeDeal();
  }

  void _executeDeal() {
    if (yourSide == null) return; // can't deal without bet

    phase = ABGamePhase.dealing;
    notifyListeners();

    // Run REAL engine — AndarBaharEngine.playRound()
    final result = AndarBaharEngine.playRound();
    jokerCard    = result.jokerCard;
    winningSpot  = result.winningSpot;
    _pendingSteps = result.dealSteps;
    _stepIndex    = 0;

    _addChat('Dealer', '🃏 Joker: ${result.jokerCard.display}', isSystem: true);

    // Reveal cards one by one with 550ms delay (animation feel)
    _dealTimer?.cancel();
    _dealTimer = Timer.periodic(const Duration(milliseconds: 550), (t) {
      if (_stepIndex >= _pendingSteps.length) {
        t.cancel();
        _resolveRound();
        return;
      }
      final step = _pendingSteps[_stepIndex];
      if (step.spot == SpotType.andar) andarCards.add(step.card);
      else                              baharCards.add(step.card);
      _stepIndex++;
      notifyListeners();
    });
  }

  // ── Resolve round ─────────────────────────────────────────────────────────
  void _resolveRound() {
    phase = ABGamePhase.roundResult;

    final won = yourSide == winningSpot;

    if (won && yourBet > 0) {
      // Real 2x payout from engine
      final payout = AndarBaharEngine.calculate2xPayout(yourBet, yourSide!, winningSpot!);
      playerState.creditWin(payout, 'Andar Bahar');
      yourTotalWon += payout;
      _addChat('Dealer', '🎉 ${winningSpot == SpotType.andar ? "ANDAR" : "BAHAR"} WINS! You won ${_fmt(payout)}! 🏆', isSystem: true);
    } else {
      playerState.recordLoss(yourBet, 'Andar Bahar');
      _addChat('Dealer', '❌ ${winningSpot == SpotType.andar ? "ANDAR" : "BAHAR"} WINS! Better luck!', isSystem: true);
    }

    // Payout bots
    _resolveBotsWinLoss();
    _syncPlayerChips();
    notifyListeners();

    // Auto start next round after 3s
    Timer(const Duration(seconds: 3), _startNewRound);
  }

  // ── Bot AI: place random bets ─────────────────────────────────────────────
  void _botsPlaceBets() {
    for (int i = 0; i < seats.length; i++) {
      if (!seats[i].isBot || seats[i].isEmpty) continue;
      if (seats[i].placedSide != null) continue; // already bet

      final side = _rng.nextBool() ? SpotType.andar : SpotType.bahar;
      final bet  = [200, 500, 1000, 2000, 5000][_rng.nextInt(5)];
      final actualBet = bet.clamp(0, seats[i].chips);
      if (actualBet == 0) continue;

      seats[i] = seats[i].copyWith(
        placedSide: side,
        currentBet: actualBet,
        chips: seats[i].chips - actualBet,
      );
      if (side == SpotType.andar) andarPool += actualBet;
      else                        baharPool += actualBet;

      _addChat(seats[i].name, '${side == SpotType.andar ? "🟢 Andar" : "🔴 Bahar"} — ${_fmt(actualBet)}');
    }
    notifyListeners();
  }

  // ── Bot win/loss resolution ───────────────────────────────────────────────
  void _resolveBotsWinLoss() {
    for (int i = 0; i < seats.length; i++) {
      if (!seats[i].isBot || seats[i].isEmpty) continue;
      final won = seats[i].placedSide == winningSpot;
      final bet = seats[i].currentBet;
      if (won) {
        seats[i] = seats[i].copyWith(chips: seats[i].chips + bet * 2);
      }
      // lost chips already deducted when bet was placed
    }
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void sendChat(String text) {
    if (text.trim().isEmpty) return;
    _addChat(playerState.name.isEmpty ? 'You' : playerState.name, text);
  }

  void sendEmoji(String emoji) {
    _addChat(playerState.name.isEmpty ? 'You' : playerState.name, emoji);
  }

  void _addChat(String sender, String text, {bool isSystem = false}) {
    chatMessages.add(ChatMessage(sender: sender, text: text, isSystem: isSystem));
    if (chatMessages.length > 50) chatMessages.removeAt(0);
    notifyListeners();
  }

  // ── Auto rebet toggle ─────────────────────────────────────────────────────
  void toggleAutoRebet() {
    autoRebet = !autoRebet;
    notifyListeners();
  }

  // ── Play again manually ────────────────────────────────────────────────────
  void playAgain() {
    _dealTimer?.cancel();
    _startNewRound();
  }

  // ── Odds (live) ────────────────────────────────────────────────────────────
  double get andarOdds => _computeOdds(andarPool, baharPool);
  double get baharOdds => _computeOdds(baharPool, andarPool);
  double _computeOdds(int myPool, int otherPool) {
    if (myPool == 0) return 2.0;
    final total = myPool + otherPool;
    return (total / myPool).clamp(1.1, 9.9);
  }

  String _fmt(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }

  @override
  void dispose() {
    _dealTimer?.cancel();
    _botTimer?.cancel();
    _bettingTimer?.cancel();
    super.dispose();
  }
}
