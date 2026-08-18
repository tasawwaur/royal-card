// ─── Player / User Model ───────────────────────────────────────────────────
class PlayerModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final int vipLevel;
  final int chips;
  final int gems;
  final double totalBalance; // in Lakhs
  final int xp;
  final int xpMax;
  final int rank;
  final PlayerStats stats;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.vipLevel,
    required this.chips,
    required this.gems,
    required this.totalBalance,
    required this.xp,
    required this.xpMax,
    required this.rank,
    required this.stats,
  });

  factory PlayerModel.demo() => const PlayerModel(
        id: '12564896',
        name: 'Player123',
        avatarUrl: '',
        level: 25,
        vipLevel: 3,
        chips: 10058,
        gems: 6,
        totalBalance: 20.31,
        xp: 250,
        xpMax: 500,
        rank: 1,
        stats: PlayerStats(
          gamesPlayed: 1240,
          gamesWon: 680,
          biggestWin: 500000,
          totalEarnings: 2031000,
        ),
      );

  String get formattedChips {
    if (chips >= 10000000) return '${(chips / 10000000).toStringAsFixed(1)} Cr';
    if (chips >= 100000) return '${(chips / 100000).toStringAsFixed(1)} L';
    if (chips >= 1000) return '${(chips / 1000).toStringAsFixed(1)}K';
    return chips.toString();
  }

  String get formattedBalance => '${totalBalance.toStringAsFixed(2)} L';
}

class PlayerStats {
  final int gamesPlayed;
  final int gamesWon;
  final int biggestWin;
  final int totalEarnings;

  const PlayerStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.biggestWin,
    required this.totalEarnings,
  });

  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;
}

// ─── Table Player Model ────────────────────────────────────────────────────
class TablePlayer {
  final String id;
  final String name;
  final String avatarUrl;
  final int chips;
  final bool isDealer;
  final bool isEmpty;
  final String seatLabel;

  const TablePlayer({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.chips,
    this.isDealer = false,
    this.isEmpty = false,
    this.seatLabel = '',
  });

  factory TablePlayer.empty(String label) => TablePlayer(
        id: '',
        name: '',
        avatarUrl: '',
        chips: 0,
        isEmpty: true,
        seatLabel: label,
      );

  String get formattedChips {
    if (chips >= 100000) return '${(chips / 100000).toStringAsFixed(1)}L';
    if (chips >= 1000) return '${chips ~/ 1000}K';
    return chips.toString();
  }
}

// ─── Game Room Model ───────────────────────────────────────────────────────
enum GameType { teenPatti, andarBahar, rummy, poker }
enum GameState { waiting, betting, dealing, result }
enum BetSide { andar, bahar, none }

class GameRoom {
  final String tableId;
  final GameType type;
  final int minBet;
  final int maxBet;
  final int onlinePlayers;
  final String variation;

  const GameRoom({
    required this.tableId,
    required this.type,
    required this.minBet,
    required this.maxBet,
    required this.onlinePlayers,
    this.variation = 'Classic',
  });
}

// ─── Andar Bahar Game State ────────────────────────────────────────────────
class AndarBaharState {
  final String jokerCard;
  final String jokerSuit;
  final List<String> andarCards;
  final List<String> baharCards;
  final GameState state;
  final BetSide? winnerSide;
  final int currentBet;
  final BetSide? selectedSide;
  final int andarPool;
  final int baharPool;
  final double andarOdds;
  final double baharOdds;
  final bool autoRebet;

  const AndarBaharState({
    this.jokerCard = '4',
    this.jokerSuit = '♣',
    this.andarCards = const [],
    this.baharCards = const [],
    this.state = GameState.betting,
    this.winnerSide,
    this.currentBet = 200,
    this.selectedSide,
    this.andarPool = 32000,
    this.baharPool = 2000,
    this.andarOdds = 2.1,
    this.baharOdds = 2.1,
    this.autoRebet = false,
  });

  AndarBaharState copyWith({
    String? jokerCard,
    String? jokerSuit,
    List<String>? andarCards,
    List<String>? baharCards,
    GameState? state,
    BetSide? winnerSide,
    int? currentBet,
    BetSide? selectedSide,
    int? andarPool,
    int? baharPool,
    double? andarOdds,
    double? baharOdds,
    bool? autoRebet,
  }) {
    return AndarBaharState(
      jokerCard: jokerCard ?? this.jokerCard,
      jokerSuit: jokerSuit ?? this.jokerSuit,
      andarCards: andarCards ?? this.andarCards,
      baharCards: baharCards ?? this.baharCards,
      state: state ?? this.state,
      winnerSide: winnerSide ?? this.winnerSide,
      currentBet: currentBet ?? this.currentBet,
      selectedSide: selectedSide ?? this.selectedSide,
      andarPool: andarPool ?? this.andarPool,
      baharPool: baharPool ?? this.baharPool,
      andarOdds: andarOdds ?? this.andarOdds,
      baharOdds: baharOdds ?? this.baharOdds,
      autoRebet: autoRebet ?? this.autoRebet,
    );
  }
}
