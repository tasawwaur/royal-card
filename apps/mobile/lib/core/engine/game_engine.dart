// ═══════════════════════════════════════════════════════════════════════════
// REAL GAME ENGINE — Ported from packages/game-rules/src/
// ═══════════════════════════════════════════════════════════════════════════
// Sources ported:
//   hand-ranking.ts   → CardEngine.evaluateHand()
//   andar-bahar-rules.ts → AndarBaharEngine.playRound()
//   betting-rules.ts  → BettingEngine
//   card-comparison.ts → CardEngine.compareHands()
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:math';

// ─── Enums ────────────────────────────────────────────────────────────────
enum Suit { spades, hearts, diamonds, clubs }
enum HandType { highCard, pair, color, sequence, pureSequence, trail }
enum SpotType { andar, bahar }
enum GameVariation { classic, joker, muflis, ak47 }

// ─── Card Model ───────────────────────────────────────────────────────────
class Card {
  final String rank; // '2'..'A' or 'JOKER'
  final Suit suit;
  final int value;   // 2..14 (A=14)

  const Card({required this.rank, required this.suit, required this.value});

  /// Display string e.g. "A ♠"
  String get display => '$rank ${suitSymbol(suit)}';

  /// Red suits
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  static String suitSymbol(Suit s) {
    switch (s) {
      case Suit.spades:   return '♠';
      case Suit.hearts:   return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs:    return '♣';
    }
  }

  // Rank values — exactly matching RANK_VALUES in hand-ranking.ts
  static const Map<String, int> rankValues = {
    '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
    '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
    'JOKER': 0,
  };

  @override
  String toString() => display;
}

// ─── Hand Evaluation Result ───────────────────────────────────────────────
class HandEvaluation {
  final HandType handType;
  final int rankValue;
  final List<Card> cards;

  const HandEvaluation({
    required this.handType,
    required this.rankValue,
    required this.cards,
  });

  String get label {
    switch (handType) {
      case HandType.trail:         return 'Trail (Set) 👑';
      case HandType.pureSequence:  return 'Pure Sequence 🔥';
      case HandType.sequence:      return 'Sequence ✨';
      case HandType.color:         return 'Color 💜';
      case HandType.pair:          return 'Pair 🃏';
      case HandType.highCard:      return 'High Card';
    }
  }
}

// ─── Andar Bahar Step ─────────────────────────────────────────────────────
class AndarBaharStep {
  final SpotType spot;
  final Card card;
  final bool isMatch;

  const AndarBaharStep({required this.spot, required this.card, required this.isMatch});
}

// ─── Andar Bahar Round State ──────────────────────────────────────────────
class AndarBaharRoundResult {
  final Card jokerCard;
  final List<AndarBaharStep> dealSteps;
  final SpotType winningSpot;
  final int totalCardsDealt;

  const AndarBaharRoundResult({
    required this.jokerCard,
    required this.dealSteps,
    required this.winningSpot,
    required this.totalCardsDealt,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// CARD ENGINE — Dart port of hand-ranking.ts + card-comparison.ts
// ═══════════════════════════════════════════════════════════════════════════
class CardEngine {
  static final Random _rng = Random.secure(); // cryptographic RNG like Node crypto

  // ── createDeck() ─────────────────────────────────────────────────────────
  // Ported from: hand-ranking.ts createDeck()
  static List<Card> createDeck() {
    const suits = Suit.values;
    const rankStrings = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
    final deck = <Card>[];
    for (final suit in suits) {
      for (final rank in rankStrings) {
        deck.add(Card(rank: rank, suit: suit, value: Card.rankValues[rank]!));
      }
    }
    return deck; // 52 cards
  }

  // ── shuffleDeck() ────────────────────────────────────────────────────────
  // Ported from: hand-ranking.ts shuffleDeck() — Fisher-Yates with secure RNG
  static List<Card> shuffleDeck(List<Card> deck) {
    final shuffled = List<Card>.from(deck);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  // ── evaluateHand() ────────────────────────────────────────────────────────
  // Ported from: hand-ranking.ts evaluateHand()
  // Hand hierarchy: Trail > Pure Sequence > Sequence > Color > Pair > High Card
  static HandEvaluation evaluateHand(List<Card> cards, {GameVariation variation = GameVariation.classic}) {
    if (cards.length != 3) throw ArgumentError('Teen Patti requires exactly 3 cards');

    // Apply variation card transforms
    final effectiveCards = _applyVariation(cards, variation);

    final sorted = List<Card>.from(effectiveCards)..sort((a, b) => b.value - a.value);
    final c1 = sorted[0], c2 = sorted[1], c3 = sorted[2];

    final isSameSuit   = c1.suit == c2.suit && c2.suit == c3.suit;
    final isTrio       = c1.value == c2.value && c2.value == c3.value;
    final isNormalSeq  = c1.value - c2.value == 1 && c2.value - c3.value == 1;
    final isA23Seq     = c1.value == 14 && c2.value == 3 && c3.value == 2;
    final isSequence   = isNormalSeq || isA23Seq;
    final isPair       = c1.value == c2.value || c2.value == c3.value || c1.value == c3.value;

    HandType handType;
    int rankValue;

    if (isTrio) {
      handType  = HandType.trail;
      rankValue = 6000000 + c1.value;
    } else if (isSameSuit && isSequence) {
      handType  = HandType.pureSequence;
      rankValue = 5000000 + (isA23Seq ? 3 : c1.value);
    } else if (isSequence) {
      handType  = HandType.sequence;
      rankValue = 4000000 + (isA23Seq ? 3 : c1.value);
    } else if (isSameSuit) {
      handType  = HandType.color;
      rankValue = 3000000 + c1.value * 100 + c2.value * 10 + c3.value;
    } else if (isPair) {
      int pairValue, kickerValue;
      if (c1.value == c2.value)      { pairValue = c1.value; kickerValue = c3.value; }
      else if (c2.value == c3.value) { pairValue = c2.value; kickerValue = c1.value; }
      else                           { pairValue = c1.value; kickerValue = c2.value; }
      handType  = HandType.pair;
      rankValue = 2000000 + pairValue * 100 + kickerValue;
    } else {
      handType  = HandType.highCard;
      rankValue = 1000000 + c1.value * 100 + c2.value * 10 + c3.value;
    }

    // Muflis: reverse ranking
    if (variation == GameVariation.muflis) {
      rankValue = 7000000 - rankValue;
      handType  = _reversedHandType(handType);
    }

    return HandEvaluation(handType: handType, rankValue: rankValue, cards: sorted);
  }

  // ── compareHands() ────────────────────────────────────────────────────────
  // Ported from: card-comparison.ts compareHands()
  // Returns +1 if handA > handB, -1 if handB > handA, 0 if tie
  static int compareHands(List<Card> handA, List<Card> handB, {GameVariation variation = GameVariation.classic}) {
    final evalA = evaluateHand(handA, variation: variation);
    final evalB = evaluateHand(handB, variation: variation);
    if (evalA.rankValue > evalB.rankValue) return 1;
    if (evalB.rankValue > evalA.rankValue) return -1;
    return 0;
  }

  // ── AK47 / Joker variation wildcard transforms ────────────────────────────
  static List<Card> _applyVariation(List<Card> cards, GameVariation variation) {
    if (variation == GameVariation.ak47) {
      // A, K, 4, 7 act as wildcards — substitute to maximise hand
      return cards.map((c) {
        final isWild = c.rank == 'A' || c.rank == 'K' || c.rank == '4' || c.rank == '7';
        if (isWild) {
          // treat as best possible rank for the suit context
          return Card(rank: c.rank, suit: c.suit, value: 14); // treat as Ace value
        }
        return c;
      }).toList();
    }
    if (variation == GameVariation.joker) {
      // JOKER cards (none in standard deck, but bot hands may include them)
      return cards.map((c) => c.rank == 'JOKER'
          ? Card(rank: 'A', suit: c.suit, value: 14)
          : c).toList();
    }
    return cards;
  }

  static HandType _reversedHandType(HandType ht) {
    // Muflis: lowest hand wins — no display change needed, rankValue already reversed
    return ht;
  }

  // ── dealHands() — deals N hands of 3 cards each from a shuffled deck ─────
  static List<List<Card>> dealHands(int playerCount) {
    final deck = shuffleDeck(createDeck());
    final hands = <List<Card>>[];
    for (int i = 0; i < playerCount; i++) {
      hands.add([deck[i * 3], deck[i * 3 + 1], deck[i * 3 + 2]]);
    }
    return hands;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANDAR BAHAR ENGINE — Dart port of andar-bahar-rules.ts
// ═══════════════════════════════════════════════════════════════════════════
class AndarBaharEngine {
  // ── playRound() ───────────────────────────────────────────────────────────
  // Ported from: andar-bahar-rules.ts playAndarBaharRound()
  // Real rules: shuffle 52-card deck → pop joker → deal alternately until rank match
  static AndarBaharRoundResult playRound() {
    final deck = CardEngine.shuffleDeck(CardEngine.createDeck());
    final joker = deck.removeLast(); // Step 1: joker card

    final dealSteps = <AndarBaharStep>[];
    SpotType currentSpot = SpotType.andar; // Step 2: first card goes to ANDAR
    SpotType? winningSpot;

    // Step 3: alternate dealing until rank matches joker
    while (deck.isNotEmpty) {
      final card = deck.removeLast();
      final isMatch = card.rank == joker.rank;

      dealSteps.add(AndarBaharStep(spot: currentSpot, card: card, isMatch: isMatch));

      if (isMatch) {
        winningSpot = currentSpot;
        break;
      }
      // Toggle ANDAR ↔ BAHAR exactly as in TS source
      currentSpot = currentSpot == SpotType.andar ? SpotType.bahar : SpotType.andar;
    }

    return AndarBaharRoundResult(
      jokerCard: joker,
      dealSteps: dealSteps,
      winningSpot: winningSpot ?? SpotType.andar,
      totalCardsDealt: dealSteps.length,
    );
  }

  // ── calculate2xPayout() ───────────────────────────────────────────────────
  // Ported from: andar-bahar-rules.ts calculate2xAndarBaharPayout()
  static int calculate2xPayout(int betAmount, SpotType betSpot, SpotType winningSpot) {
    return betSpot == winningSpot ? betAmount * 2 : 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BETTING ENGINE — Dart port of betting-rules.ts
// ═══════════════════════════════════════════════════════════════════════════
class BettingEngine {
  // ── calculateRequiredBet() ────────────────────────────────────────────────
  // Ported from: betting-rules.ts calculateRequiredBet()
  static int calculateRequiredBet(int currentBet, {bool isBlind = false, bool chaalMultiplier = false}) {
    int base = isBlind ? currentBet ~/ 2 : currentBet;
    if (chaalMultiplier) base *= 2;
    return base;
  }

  // ── isValidBetAmount() ────────────────────────────────────────────────────
  // Ported from: betting-rules.ts isValidBetAmount()
  static bool isValidBetAmount(int requested, int currentBet, {bool isBlind = false, int chaalLimit = 100000}) {
    if (requested > chaalLimit) return false;
    final min = isBlind ? ((currentBet / 2).ceil()) : currentBet;
    final max = min * 2;
    return requested >= min && requested <= max;
  }

  // ── Real chip deduction/addition ──────────────────────────────────────────
  static int deductBet(int wallet, int bet) {
    if (bet > wallet) throw Exception('Insufficient chips');
    return wallet - bet;
  }

  static int creditWinnings(int wallet, int winAmount) => wallet + winAmount;
}
