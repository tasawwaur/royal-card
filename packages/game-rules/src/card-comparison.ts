import { Card } from '@teenpatti/shared-types';
import { evaluateHand } from './hand-ranking';

export interface ComparisonResult {
  winnerHand: Card[];
  loserHand: Card[];
  isTie: boolean;
}

// Compares two 3-card hands. Returns +1 if handA > handB, -1 if handB > handA, 0 if tie
export function compareHands(handA: Card[], handB: Card[]): number {
  const evalA = evaluateHand(handA);
  const evalB = evaluateHand(handB);

  if (evalA.rankValue > evalB.rankValue) return 1;
  if (evalB.rankValue > evalA.rankValue) return -1;
  return 0;
}
