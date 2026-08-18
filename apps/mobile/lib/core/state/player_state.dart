import 'package:flutter/foundation.dart';
import '../engine/game_engine.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLAYER STATE — Real wallet, chips, profile, invite
// ═══════════════════════════════════════════════════════════════════════════
class PlayerState extends ChangeNotifier {
  // ── Core identity ─────────────────────────────────────────────────────────
  String _id      = _generateId();
  String _name    = 'Player';
  int    _vipLevel = 1;
  int    _level    = 1;
  int    _xp       = 0;
  int    _xpMax    = 500;
  int    _rank     = 0;

  // ── Real Wallet ───────────────────────────────────────────────────────────
  int _chips = 10058;      // real chip balance (not demo placeholder)
  int _gems  = 6;

  // ── Stats (update on every game result) ──────────────────────────────────
  int _gamesPlayed = 0;
  int _gamesWon    = 0;
  int _biggestWin  = 0;

  // ── Transaction history ───────────────────────────────────────────────────
  final List<WalletTransaction> _transactions = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  String get id       => _id;
  String get name     => _name;
  int get vipLevel    => _vipLevel;
  int get level       => _level;
  int get xp          => _xp;
  int get xpMax       => _xpMax;
  int get rank        => _rank;
  int get chips       => _chips;
  int get gems        => _gems;
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon    => _gamesWon;
  int get biggestWin  => _biggestWin;
  double get winRate  => _gamesPlayed > 0 ? _gamesWon / _gamesPlayed * 100 : 0;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  double get totalBalanceLakhs => _chips / 100000.0;

  String get formattedChips {
    if (_chips >= 10000000) return '${(_chips / 10000000).toStringAsFixed(2)} Cr';
    if (_chips >= 100000)   return '${(_chips / 100000).toStringAsFixed(2)} L';
    if (_chips >= 1000)     return '${(_chips / 1000).toStringAsFixed(0)}K';
    return '$_chips';
  }

  // ── Profile setup ─────────────────────────────────────────────────────────
  void setupProfile({required String name, int startingChips = 10058}) {
    _name  = name;
    _chips = startingChips;
    _id    = _generateId();
    notifyListeners();
  }

  // ── Real chip deduction (BettingEngine.deductBet) ─────────────────────────
  bool placeBet(int amount) {
    if (amount > _chips) return false; // insufficient
    _chips = BettingEngine.deductBet(_chips, amount);
    _transactions.add(WalletTransaction(
      label: 'Bet placed',
      amount: -amount,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  // ── Real chip credit (BettingEngine.creditWinnings) ───────────────────────
  void creditWin(int amount, String gameLabel) {
    _chips = BettingEngine.creditWinnings(_chips, amount);
    _gamesWon++;
    _gamesPlayed++;
    if (amount > _biggestWin) _biggestWin = amount;
    _addXP(amount ~/ 100);
    _transactions.add(WalletTransaction(
      label: 'Won — $gameLabel',
      amount: amount,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ── Record loss ───────────────────────────────────────────────────────────
  void recordLoss(int amount, String gameLabel) {
    _gamesPlayed++;
    _addXP(10);
    _transactions.add(WalletTransaction(
      label: 'Lost — $gameLabel',
      amount: -amount,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ── Daily bonus ───────────────────────────────────────────────────────────
  void claimDailyBonus(int bonusChips) {
    _chips += bonusChips;
    _transactions.add(WalletTransaction(
      label: 'Daily Bonus',
      amount: bonusChips,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ── XP & Level up ────────────────────────────────────────────────────────
  void _addXP(int amount) {
    _xp += amount;
    while (_xp >= _xpMax) {
      _xp   -= _xpMax;
      _level++;
      _xpMax  = (_xpMax * 1.2).round();
      _updateVIP();
    }
  }

  void _updateVIP() {
    if (_level >= 50)      _vipLevel = 5;
    else if (_level >= 30) _vipLevel = 4;
    else if (_level >= 20) _vipLevel = 3;
    else if (_level >= 10) _vipLevel = 2;
    else                   _vipLevel = 1;
  }

  static String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (10000000 + now % 90000000).toString();
  }
}

// ─── Wallet Transaction ───────────────────────────────────────────────────
class WalletTransaction {
  final String label;
  final int amount;      // positive = credit, negative = debit
  final DateTime timestamp;

  const WalletTransaction({
    required this.label,
    required this.amount,
    required this.timestamp,
  });

  bool get isCredit => amount > 0;

  String get formattedAmount {
    final abs = amount.abs();
    if (abs >= 100000) return '${(abs / 100000).toStringAsFixed(1)}L';
    if (abs >= 1000)   return '${(abs / 1000).toStringAsFixed(0)}K';
    return '$abs';
  }
}
