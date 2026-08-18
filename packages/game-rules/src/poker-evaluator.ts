import { Card, PokerHandRank } from '@teenpatti/shared-types';

export interface PokerHandEvaluation {
  rank: PokerHandRank;
  score: number;
  bestFiveCards: Card[];
}

// Evaluates a 7-card hand (2 hole cards + 5 community cards) in Texas Hold'em
export function evaluatePoker7Cards(cards: Card[]): PokerHandEvaluation {
  if (cards.length < 5 || cards.length > 7) {
    throw new Error('Poker evaluation requires 5 to 7 cards.');
  }

  // Generate all 5-card combinations from the 7 cards
  const combinations = getCombinations(cards, 5);
  let bestEval: PokerHandEvaluation | null = null;

  for (const combo of combinations) {
    const evalResult = evaluatePoker5Cards(combo);
    if (!bestEval || evalResult.score > bestEval.score) {
      bestEval = evalResult;
    }
  }

  return bestEval!;
}

export function evaluatePoker5Cards(cards: Card[]): PokerHandEvaluation {
  const sorted = [...cards].sort((a, b) => b.value - a.value);
  const [c1, c2, c3, c4, c5] = sorted;

  const isFlush = cards.every((c) => c.suit === cards[0].suit);
  const values = sorted.map((c) => c.value);
  
  // Check sequence
  const isNormalSeq =
    values[0] - values[1] === 1 &&
    values[1] - values[2] === 1 &&
    values[2] - values[3] === 1 &&
    values[3] - values[4] === 1;

  const isAceLowSeq = values[0] === 14 && values[1] === 5 && values[2] === 4 && values[3] === 3 && values[4] === 2;
  const isStraight = isNormalSeq || isAceLowSeq;

  // Value frequency counts
  const counts: Record<number, number> = {};
  values.forEach((v) => (counts[v] = (counts[v] || 0) + 1));
  const freqValues = Object.entries(counts).map(([v, count]) => ({ val: Number(v), count }));
  freqValues.sort((a, b) => b.count - a.count || b.val - a.val);

  let rank: PokerHandRank;
  let score = 0;

  if (isFlush && isStraight) {
    if (values[0] === 14 && values[1] === 13) {
      rank = 'ROYAL_FLUSH';
      score = 9000000;
    } else {
      rank = 'STRAIGHT_FLUSH';
      score = 8000000 + (isAceLowSeq ? 5 : values[0]);
    }
  } else if (freqValues[0].count === 4) {
    rank = 'FOUR_OF_A_KIND';
    score = 7000000 + freqValues[0].val * 10 + freqValues[1].val;
  } else if (freqValues[0].count === 3 && freqValues[1].count === 2) {
    rank = 'FULL_HOUSE';
    score = 6000000 + freqValues[0].val * 10 + freqValues[1].val;
  } else if (isFlush) {
    rank = 'FLUSH';
    score = 5000000 + values[0] * 1000 + values[1] * 100 + values[2] * 10 + values[3];
  } else if (isStraight) {
    rank = 'STRAIGHT';
    score = 4000000 + (isAceLowSeq ? 5 : values[0]);
  } else if (freqValues[0].count === 3) {
    rank = 'THREE_OF_A_KIND';
    score = 3000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else if (freqValues[0].count === 2 && freqValues[1].count === 2) {
    rank = 'TWO_PAIR';
    score = 2000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else if (freqValues[0].count === 2) {
    rank = 'ONE_PAIR';
    score = 1000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else {
    rank = 'HIGH_CARD';
    score = values[0] * 1000 + values[1] * 100 + values[2] * 10 + values[3];
  }

  return { rank, score, bestFiveCards: sorted };
}

function getCombinations<T>(array: T[], size: number): T[][] {
  const result: T[][] = [];
  function p(t: T[], i: number) {
    if (t.length === size) {
      result.push(t);
      return;
    }
    if (i + (size - t.length) > array.length) return;
    p([...t, array[i]], i + 1);
    p(t, i + 1);
  }
  p([], 0);
  return result;
}
