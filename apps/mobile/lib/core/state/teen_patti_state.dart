import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../engine/game_engine.dart';
import 'player_state.dart';
import 'andar_bahar_state.dart' show TableSeat, ChatMessage;

// ═══════════════════════════════════════════════════════════════════════════
// TEEN PATTI PLAYER STATUS at table
// ═══════════════════════════════════════════════════════════════════════════
enum TPStatus { waiting, blind, seen, packed, winner }

class TPSeat extends TableSeat {
  TPStatus tpStatus;
  List<Card> hand;          // real 3-card hand from engine
  HandEvaluation? eval;     // evaluated when cards are shown
  bool isCurrentTurn;

  TPSeat({
    required super.seatId,
    required super.name,
    required super.chips,
    super.isYou, super.isBot, super.isEmpty,
    super.avatarEmoji,
    this.tpStatus = TPStatus.waiting,
    this.hand     = const [],
    this.eval,
    this.isCurrentTurn = false,
  });

  factory TPSeat.empty(String seatId) => TPSeat(
    seatId: seatId, name: '', chips: 0, isEmpty: true, avatarEmoji: '➕',
  );

  @override
  TPSeat copyWith({
    String? name, int? chips, int? currentBet,
    SpotType? placedSide, bool? isOnline, bool? isTurn,
    TPStatus? tpStatus, List<Card>? hand, HandEvaluation? eval, bool? isCurrentTurn,
  }) => TPSeat(
    seatId: seatId, name: name ?? this.name, chips: chips ?? this.chips,
    isYou: isYou, isBot: isBot, isEmpty: false,
    avatarEmoji: avatarEmoji,
    tpStatus: tpStatus ?? this.tpStatus,
    hand: hand ?? this.hand,
    eval: eval ?? this.eval,
    isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TEEN PATTI GAME STATE — real engine, real chips, real betting rules
// ═══════════════════════════════════════════════════════════════════════════
enum TPPhase { waiting, playing, showdown, roundResult }

class TeenPattiGameState extends ChangeNotifier {
  final PlayerState playerState;
  final GameVariation variation;
  final Random _rng = Random.secure();

  // ── Seats ─────────────────────────────────────────────────────────────────
  late List<TPSeat> seats;

  // ── Round state ───────────────────────────────────────────────────────────
  TPPhase phase = TPPhase.waiting;
  int pot = 0;
  int bootAmount;
  int currentBet;
  int roundNumber = 0;
  int turnIndex = 0;           // index into activePlayers
  int turnSecondsLeft = 30;
  Timer? _turnTimer;
  Timer? _botTimer;

  // ── Chat ──────────────────────────────────────────────────────────────────
  final List<ChatMessage> chatMessages = [];

  // ── Winner ────────────────────────────────────────────────────────────────
  String? winnerName;
  HandEvaluation? winnerEval;
  int? winnerPot;

  TeenPattiGameState({
    required this.playerState,
    this.variation  = GameVariation.classic,
    this.bootAmount = 100,
    this.currentBet = 100,
  }) {
    _initSeats();
    _startRound();
  }

  // ── Init seats: YOU + bots ─────────────────────────────────────────────────
  void _initSeats() {
    seats = [
      TPSeat(seatId: 'S1', name: 'Fahad',     chips: 32000,  isBot: true,  avatarEmoji: '🎩'),
      TPSeat(seatId: 'S2', name: 'RajKing',   chips: 45000,  isBot: true,  avatarEmoji: '👑'),
      TPSeat(seatId: 'S3',
        name: playerState.name.isEmpty ? 'You' : playerState.name,
        chips: playerState.chips,
        isYou: true,
        avatarEmoji: '🌟',
      ),
      TPSeat(seatId: 'S4', name: 'HODAYATSOP', chips: 15000, isBot: true,  avatarEmoji: '🦊'),
      TPSeat(seatId: 'S5', name: 'GoldAce',    chips: 28000, isBot: true,  avatarEmoji: '🃏'),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INVITE real player to seat
  // ═══════════════════════════════════════════════════════════════════════════
  void inviteToSeat(String seatId, {String? friendName}) {
    final index = seats.indexWhere((s) => s.seatId == seatId);
    if (index < 0) return;
    final name = friendName ?? 'Guest_${_rng.nextInt(9999)}';
    seats[index] = TPSeat(
      seatId: seatId, name: name,
      chips: 10000 + _rng.nextInt(40000),
      isBot: friendName == null,
      avatarEmoji: '🤝',
      tpStatus: TPStatus.waiting,
    );
    _addChat('System', '✅ $name joined seat $seatId', isSystem: true);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // START ROUND — real deal from engine
  // ═══════════════════════════════════════════════════════════════════════════
  void _startRound() {
    roundNumber++;
    pot = 0;
    turnIndex = 0;
    winnerName = null;
    winnerEval = null;
    winnerPot  = null;

    // Collect boot from all active players
    final activeSeatIds = <String>[];
    for (int i = 0; i < seats.length; i++) {
      if (seats[i].isEmpty) continue;
      final bootPay = bootAmount.clamp(0, seats[i].chips);
      seats[i] = seats[i].copyWith(chips: seats[i].chips - bootPay, tpStatus: TPStatus.blind);
      pot += bootPay;
      activeSeatIds.add(seats[i].seatId);
    }

    // Real deal: CardEngine.dealHands() — Fisher-Yates shuffled 52-card deck
    final hands = CardEngine.dealHands(seats.length);
    for (int i = 0; i < seats.length; i++) {
      if (seats[i].isEmpty) continue;
      seats[i] = seats[i].copyWith(hand: hands[i], tpStatus: TPStatus.blind);
    }

    // Deduct boot from player wallet too
    final yourIndex = seats.indexWhere((s) => s.isYou);
    if (yourIndex >= 0) {
      playerState.placeBet(bootAmount.clamp(0, playerState.chips));
      seats[yourIndex] = seats[yourIndex].copyWith(chips: playerState.chips);
    }

    phase = TPPhase.playing;
    currentBet = bootAmount;
    _setCurrentTurn(0);
    _addChat('Dealer', '🃏 Round $roundNumber started — Boot: ${_fmt(bootAmount)}', isSystem: true);
    notifyListeners();
    _scheduleBotTurn();
  }

  // ── Active (non-packed) seats ─────────────────────────────────────────────
  List<int> get activeIndices => [
    for (int i = 0; i < seats.length; i++)
      if (!seats[i].isEmpty && seats[i].tpStatus != TPStatus.packed) i
  ];

  void _setCurrentTurn(int activeIndex) {
    final active = activeIndices;
    if (active.isEmpty) return;
    final idx = active[activeIndex % active.length];
    for (int i = 0; i < seats.length; i++) {
      seats[i] = seats[i].copyWith(isCurrentTurn: i == idx);
    }
    _startTurnTimer();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PLAYER ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  // ── See Cards ─────────────────────────────────────────────────────────────
  void seeCards() {
    final idx = seats.indexWhere((s) => s.isYou);
    if (idx < 0 || seats[idx].tpStatus != TPStatus.blind) return;
    seats[idx] = seats[idx].copyWith(tpStatus: TPStatus.seen);
    _addChat(seats[idx].name, '👀 I see my cards');
    notifyListeners();
  }

  // ── Pack (Fold) ────────────────────────────────────────────────────────────
  void pack() {
    final idx = seats.indexWhere((s) => s.isYou);
    if (idx < 0) return;
    seats[idx] = seats[idx].copyWith(tpStatus: TPStatus.packed);
    _addChat(seats[idx].name, '🙅 I Pack (Fold)');
    playerState.recordLoss(0, 'Teen Patti');
    notifyListeners();
    _checkRoundEnd();
  }

  // ── Blind (bet without seeing) ─────────────────────────────────────────────
  /// Returns error or null
  String? blind() {
    final idx = seats.indexWhere((s) => s.isYou);
    if (idx < 0) return 'Seat not found';
    if (seats[idx].tpStatus == TPStatus.seen) return 'Already seen — use Chaal';

    // BettingEngine: blind pays currentBet / 2
    final betAmt = BettingEngine.calculateRequiredBet(currentBet, isBlind: true);
    if (betAmt > playerState.chips) return 'Insufficient chips';

    playerState.placeBet(betAmt);
    pot += betAmt;
    seats[idx] = seats[idx].copyWith(chips: playerState.chips);
    _addChat(seats[idx].name, '🤫 Blind — ${_fmt(betAmt)}');
    notifyListeners();
    _nextTurn();
    return null;
  }

  // ── Chaal (bet after seeing) ───────────────────────────────────────────────
  String? chaal(int betAmount) {
    final idx = seats.indexWhere((s) => s.isYou);
    if (idx < 0) return 'Seat not found';

    // Validate using BettingEngine
    final valid = BettingEngine.isValidBetAmount(
      betAmount, currentBet,
      isBlind: seats[idx].tpStatus == TPStatus.blind,
      chaalLimit: 100000,
    );
    if (!valid) return 'Invalid bet amount';
    if (betAmount > playerState.chips) return 'Insufficient chips';

    playerState.placeBet(betAmount);
    pot += betAmount;
    currentBet = betAmount;
    seats[idx] = seats[idx].copyWith(chips: playerState.chips, tpStatus: TPStatus.seen);
    _addChat(seats[idx].name, '💰 Chaal — ${_fmt(betAmount)}');
    notifyListeners();
    _nextTurn();
    return null;
  }

  // ── Side Show ─────────────────────────────────────────────────────────────
  // Compare cards with previous seen player
  bool requestSideShow() {
    final yourIdx = seats.indexWhere((s) => s.isYou);
    if (yourIdx < 0) return false;
    if (seats[yourIdx].tpStatus != TPStatus.seen) return false;

    // Find previous seen player
    final active = activeIndices;
    final myPos = active.indexOf(yourIdx);
    if (myPos <= 0) return false;
    final prevIdx = active[myPos - 1];
    if (seats[prevIdx].tpStatus != TPStatus.seen) return false;

    // Compare hands using CardEngine.compareHands
    final result = CardEngine.compareHands(seats[yourIdx].hand, seats[prevIdx].hand, variation: variation);
    if (result >= 0) {
      // You win side show — opponent packs
      seats[prevIdx] = seats[prevIdx].copyWith(tpStatus: TPStatus.packed);
      _addChat('Dealer', '⚔️ Side Show: ${seats[yourIdx].name} wins vs ${seats[prevIdx].name}', isSystem: true);
    } else {
      // You lose side show — you pack
      seats[yourIdx] = seats[yourIdx].copyWith(tpStatus: TPStatus.packed);
      playerState.recordLoss(0, 'Teen Patti');
      _addChat('Dealer', '⚔️ Side Show: ${seats[prevIdx].name} wins vs ${seats[yourIdx].name}', isSystem: true);
    }
    notifyListeners();
    _checkRoundEnd();
    return true;
  }

  // ── Show (final reveal) ────────────────────────────────────────────────────
  void show() {
    final active = activeIndices;
    if (active.length > 2) return; // need exactly 2 to show

    // Reveal and compare all remaining hands
    for (final idx in active) {
      if (seats[idx].hand.isEmpty) continue;
      seats[idx] = seats[idx].copyWith(
        tpStatus: TPStatus.seen,
        eval: CardEngine.evaluateHand(seats[idx].hand, variation: variation),
      );
    }
    phase = TPPhase.showdown;
    notifyListeners();

    // Find best hand
    _determineWinner(active);
  }

  // ── Determine winner ──────────────────────────────────────────────────────
  void _determineWinner(List<int> activeIdx) {
    if (activeIdx.isEmpty) return;

    int bestIdx = activeIdx[0];
    for (final idx in activeIdx.skip(1)) {
      final cmp = CardEngine.compareHands(seats[idx].hand, seats[bestIdx].hand, variation: variation);
      if (cmp > 0) bestIdx = idx;
    }

    seats[bestIdx] = seats[bestIdx].copyWith(
      tpStatus: TPStatus.winner,
      eval: CardEngine.evaluateHand(seats[bestIdx].hand, variation: variation),
    );

    winnerName = seats[bestIdx].name;
    winnerEval = seats[bestIdx].eval;
    winnerPot  = pot;

    if (seats[bestIdx].isYou) {
      playerState.creditWin(pot, 'Teen Patti');
      seats[bestIdx] = seats[bestIdx].copyWith(chips: playerState.chips);
    } else {
      seats[bestIdx] = seats[bestIdx].copyWith(chips: seats[bestIdx].chips + pot);
      playerState.recordLoss(0, 'Teen Patti');
    }

    pot = 0;
    phase = TPPhase.roundResult;
    _addChat('Dealer', '🏆 ${seats[bestIdx].name} wins with ${seats[bestIdx].eval?.label}!', isSystem: true);
    notifyListeners();

    // Next round in 4s
    Timer(const Duration(seconds: 4), _startRound);
  }

  // ─── Bot turn logic ────────────────────────────────────────────────────────
  void _scheduleBotTurn() {
    final active = activeIndices;
    if (active.isEmpty) return;
    final currIdx = active[turnIndex % active.length];
    if (!seats[currIdx].isBot) return; // human turn

    _botTimer = Timer(Duration(milliseconds: 800 + _rng.nextInt(1500)), () {
      _doBotAction(currIdx);
    });
  }

  void _doBotAction(int idx) {
    if (idx >= seats.length || seats[idx].isEmpty) return;

    final roll = _rng.nextInt(100);
    if (roll < 10 && activeIndices.length > 2) {
      // 10% chance pack
      seats[idx] = seats[idx].copyWith(tpStatus: TPStatus.packed);
      _addChat(seats[idx].name, '🙅 Pack');
    } else {
      // bet blind/chaal
      final isBlind = seats[idx].tpStatus == TPStatus.blind;
      final bet = BettingEngine.calculateRequiredBet(currentBet, isBlind: isBlind);
      final pay = bet.clamp(0, seats[idx].chips);
      pot += pay;
      seats[idx] = seats[idx].copyWith(
        chips: seats[idx].chips - pay,
        tpStatus: isBlind ? TPStatus.blind : TPStatus.seen,
      );
      _addChat(seats[idx].name, '${isBlind ? "🤫 Blind" : "💰 Chaal"} — ${_fmt(pay)}');
    }
    notifyListeners();
    _nextTurn();
  }

  void _nextTurn() {
    _turnTimer?.cancel();
    final active = activeIndices;
    if (active.isEmpty) { _checkRoundEnd(); return; }
    turnIndex = (turnIndex + 1) % active.length;
    _setCurrentTurn(turnIndex);
    notifyListeners();
    _checkRoundEnd();
    _scheduleBotTurn();
  }

  void _checkRoundEnd() {
    final active = activeIndices;
    if (active.length == 1) {
      // Only one player left — wins by default
      _determineWinner(active);
    }
  }

  // ── Turn countdown ────────────────────────────────────────────────────────
  void _startTurnTimer() {
    _turnTimer?.cancel();
    turnSecondsLeft = 30;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      turnSecondsLeft--;
      notifyListeners();
      if (turnSecondsLeft <= 0) {
        t.cancel();
        // Auto-fold if player doesn't act
        final active = activeIndices;
        if (active.isEmpty) return;
        final currIdx = active[turnIndex % active.length];
        if (seats[currIdx].isYou) {
          pack();
        } else {
          _doBotAction(currIdx);
        }
      }
    });
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void sendChat(String text) {
    if (text.trim().isEmpty) return;
    _addChat(playerState.name.isEmpty ? 'You' : playerState.name, text);
  }

  void _addChat(String sender, String text, {bool isSystem = false}) {
    chatMessages.add(ChatMessage(sender: sender, text: text, isSystem: isSystem));
    if (chatMessages.length > 50) chatMessages.removeAt(0);
    notifyListeners();
  }

  String _fmt(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return '$v';
  }

  bool get isYourTurn {
    final active = activeIndices;
    if (active.isEmpty) return false;
    final idx = active[turnIndex % active.length];
    return seats[idx].isYou;
  }

  int get yourIndex => seats.indexWhere((s) => s.isYou);
  TPSeat? get yourSeat => yourIndex >= 0 ? seats[yourIndex] : null;

  @override
  void dispose() {
    _turnTimer?.cancel();
    _botTimer?.cancel();
    super.dispose();
  }
}
