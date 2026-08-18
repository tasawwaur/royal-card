import { Card, CardGroup, MeldType } from '@teenpatti/shared-types';

export interface RummyDeclareValidation {
  isValid: boolean;
  totalScore: number;
  groups: CardGroup[];
}

export function validateRummyGroup(cards: Card[], wildJokerRank: string): MeldType {
  if (cards.length < 3) return 'INVALID';

  const isPureSeq = checkPureSequence(cards);
  if (isPureSeq) return 'PURE_SEQUENCE';

  const isImpureSeq = checkImpureSequence(cards, wildJokerRank);
  if (isImpureSeq) return 'IMPURE_SEQUENCE';

  const isSet = checkSet(cards, wildJokerRank);
  if (isSet) return 'SET';

  return 'INVALID';
}

function checkPureSequence(cards: Card[]): boolean {
  if (cards.length < 3) return false;
  const sameSuit = cards.every((c) => c.suit === cards[0].suit);
  if (!sameSuit) return false;

  const sorted = [...cards].sort((a, b) => a.value - b.value);
  for (let i = 0; i < sorted.length - 1; i++) {
    if (sorted[i + 1].value - sorted[i].value !== 1) return false;
  }
  return true;
}

function checkImpureSequence(cards: Card[], wildJokerRank: string): boolean {
  if (cards.length < 3) return false;
  // Non-joker cards must share the same suit
  const nonJokers = cards.filter((c) => c.rank !== wildJokerRank && c.rank !== 'JOKER');
  if (nonJokers.length === 0) return true; // All jokers

  const targetSuit = nonJokers[0].suit;
  if (!nonJokers.every((c) => c.suit === targetSuit)) return false;

  return true;
}

function checkSet(cards: Card[], wildJokerRank: string): boolean {
  if (cards.length < 3 || cards.length > 4) return false;
  const nonJokers = cards.filter((c) => c.rank !== wildJokerRank && c.rank !== 'JOKER');
  if (nonJokers.length === 0) return true;

  const targetRank = nonJokers[0].rank;
  const sameRank = nonJokers.every((c) => c.rank === targetRank);
  if (!sameRank) return false;

  // Suits must be distinct for a valid set
  const suits = new Set(nonJokers.map((c) => c.suit));
  return suits.size === nonJokers.length;
}

export function validate13CardDeclaration(groups: Card[][], wildJokerRank: string): RummyDeclareValidation {
  const evaluatedGroups: CardGroup[] = [];
  let pureSequenceCount = 0;
  let sequenceCount = 0;
  let totalScore = 0;

  for (const groupCards of groups) {
    const type = validateRummyGroup(groupCards, wildJokerRank);
    const points = type === 'INVALID' ? groupCards.reduce((acc, c) => acc + c.value, 0) : 0;
    
    if (type === 'PURE_SEQUENCE') {
      pureSequenceCount++;
      sequenceCount++;
    } else if (type === 'IMPURE_SEQUENCE') {
      sequenceCount++;
    }

    evaluatedGroups.push({
      cards: groupCards,
      type,
      points,
    });

    totalScore += points;
  }

  // 13-card Rummy rules: Must have at least 1 Pure Sequence AND at least 1 other Sequence (Pure or Impure)
  const isValid = pureSequenceCount >= 1 && sequenceCount >= 2 && evaluatedGroups.every((g) => g.type !== 'INVALID');

  return {
    isValid,
    totalScore: isValid ? 0 : Math.min(totalScore, 80), // Max penalty cap is 80 points
    groups: evaluatedGroups,
  };
}
