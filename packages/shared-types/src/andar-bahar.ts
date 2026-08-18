import { Card } from './cards';

export type SpotType = 'ANDAR' | 'BAHAR';
export type AndarBaharState = 'BETTING' | 'DEALING' | 'ENDED';

export interface AndarBaharBet {
  userId: string;
  spot: SpotType;
  amount: string;
}

export interface AndarBaharGame {
  gameId: string;
  jokerCard: Card;
  andarCards: Card[];
  baharCards: Card[];
  winningSpot?: SpotType;
  totalDealtCards: number;
  state: AndarBaharState;
  bets: AndarBaharBet[];
}
