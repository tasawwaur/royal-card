import { randomInt } from 'node:crypto';
import { Card, HandEvaluation, HandType, Rank, Suit } from '@teenpatti/shared-types';

export const RANK_VALUES: Record<Rank, number> = {
  '2': 2,
  '3': 3,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
  '10': 10,
  'J': 11,
  'Q': 12,
  'K': 13,
  'A': 14,
  'JOKER': 0,
};

export function createDeck(): Card[] {
  const suits: Suit[] = ['SPADES', 'HEARTS', 'DIAMONDS', 'CLUBS'];
  const ranks: Rank[] = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
  const deck: Card[] = [];

  for (const suit of suits) {
    for (const rank of ranks) {
      deck.push({
        suit,
        rank,
        value: RANK_VALUES[rank],
      });
    }
  }

  return deck;
}

// Secure Fisher-Yates shuffle using Node crypto.randomInt
export function shuffleDeck(deck: Card[]): Card[] {
  const shuffled = [...deck];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const randomIndex = randomInt(0, i + 1);
    const temp = shuffled[i];
    shuffled[i] = shuffled[randomIndex];
    shuffled[randomIndex] = temp;
  }
  return shuffled;
}

// Server-authoritative 3-card hand evaluator for Teen Patti
// Hand hierarchy: Trio (Trail) > Pure Sequence > Sequence > Color > Pair > High Card
export function evaluateHand(cards: Card[]): HandEvaluation {
  if (cards.length !== 3) {
    throw new Error('Teen Patti hand evaluation requires exactly 3 cards.');
  }

  const sorted = [...cards].sort((a, b) => b.value - a.value);
  const [c1, c2, c3] = sorted;

  const isSameSuit = c1.suit === c2.suit && c2.suit === c3.suit;
  const isTrio = c1.value === c2.value && c2.value === c3.value;

  const isNormalSequence = c1.value - c2.value === 1 && c2.value - c3.value === 1;
  const isA23Sequence = c1.value === 14 && c2.value === 3 && c3.value === 2; // A-3-2 / A-2-3
  const isSequence = isNormalSequence || isA23Sequence;

  const isPair = c1.value === c2.value || c2.value === c3.value || c1.value === c3.value;

  let handType: HandType;
  let rankValue = 0;

  if (isTrio) {
    handType = 'TRAIL';
    rankValue = 6000000 + c1.value;
  } else if (isSameSuit && isSequence) {
    handType = 'PURE_SEQUENCE';
    const seqHigh = isA23Sequence ? 3 : c1.value;
    rankValue = 5000000 + seqHigh;
  } else if (isSequence) {
    handType = 'SEQUENCE';
    const seqHigh = isA23Sequence ? 3 : c1.value;
    rankValue = 4000000 + seqHigh;
  } else if (isSameSuit) {
    handType = 'COLOR';
    rankValue = 3000000 + c1.value * 100 + c2.value * 10 + c3.value;
  } else if (isPair) {
    handType = 'PAIR';
    let pairValue = 0;
    let kickerValue = 0;
    if (c1.value === c2.value) {
      pairValue = c1.value;
      kickerValue = c3.value;
    } else if (c2.value === c3.value) {
      pairValue = c2.value;
      kickerValue = c1.value;
    } else {
      pairValue = c1.value;
      kickerValue = c2.value;
    }
    rankValue = 2000000 + pairValue * 100 + kickerValue;
  } else {
    handType = 'HIGH_CARD';
    rankValue = 1000000 + c1.value * 100 + c2.value * 10 + c3.value;
  }

  return {
    handType,
    rankValue,
    cards: sorted,
  };
}
