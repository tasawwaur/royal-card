import { Card } from './cards';

export type MeldType = 'PURE_SEQUENCE' | 'IMPURE_SEQUENCE' | 'SET' | 'INVALID';

export interface CardGroup {
  cards: Card[];
  type: MeldType;
  points: number;
}

export interface RummyPlayer {
  userId: string;
  hand: Card[];
  isDeclared: boolean;
  score: number;
}

export interface RummyGameState {
  gameId: string;
  wildJoker: Card;
  openDeck: Card[];
  closedDeckCount: number;
  currentTurnSeat: number;
  players: RummyPlayer[];
}
