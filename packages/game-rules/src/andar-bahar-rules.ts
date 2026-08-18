import { Card, SpotType } from '@teenpatti/shared-types';
import { createDeck, shuffleDeck } from './hand-ranking';

export interface AndarBaharStep {
  spot: SpotType;
  card: Card;
  isMatch: boolean;
}

export interface AndarBaharRoundState {
  jokerCard: Card;
  dealSteps: AndarBaharStep[];
  winningSpot: SpotType;
  totalCardsDealt: number;
}

export function playAndarBaharRound(): AndarBaharRoundState {
  const fullDeck = shuffleDeck(createDeck());
  // Step 1: Center Joker card dropped first
  const jokerCard = fullDeck.pop()!;

  const dealSteps: AndarBaharStep[] = [];
  let currentSpot: SpotType = 'ANDAR';
  let winningSpot: SpotType | null = null;

  // Step 3: Cards dealt alternately until matching Joker rank appears
  while (fullDeck.length > 0) {
    const card = fullDeck.pop()!;
    const isMatch = card.rank === jokerCard.rank;

    dealSteps.push({
      spot: currentSpot,
      card,
      isMatch,
    });

    if (isMatch) {
      winningSpot = currentSpot;
      break;
    }

    // Toggle between ANDAR and BAHAR
    currentSpot = currentSpot === 'ANDAR' ? 'BAHAR' : 'ANDAR';
  }

  return {
    jokerCard,
    dealSteps,
    winningSpot: winningSpot || 'ANDAR',
    totalCardsDealt: dealSteps.length,
  };
}

// 2x Multiplier Rule requested by user: Winning bet receives 2x payout (200% return)
export function calculate2xAndarBaharPayout(betAmount: number, betSpot: SpotType, winningSpot: SpotType): number {
  if (betSpot === winningSpot) {
    return betAmount * 2; // 2x return
  }
  return 0; // Lost bet
}
