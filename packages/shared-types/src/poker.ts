import { Card } from './cards';

export type PokerHandRank =
  | 'ROYAL_FLUSH'
  | 'STRAIGHT_FLUSH'
  | 'FOUR_OF_A_KIND'
  | 'FULL_HOUSE'
  | 'FLUSH'
  | 'STRAIGHT'
  | 'THREE_OF_A_KIND'
  | 'TWO_PAIR'
  | 'ONE_PAIR'
  | 'HIGH_CARD';

export type PokerBettingRound = 'PRE_FLOP' | 'FLOP' | 'TURN' | 'RIVER' | 'SHOWDOWN';

export interface PokerPlayer {
  userId: string;
  seatIndex: number;
  chips: string;
  currentBet: string;
  holeCards?: Card[]; // Sanitized for self only
  hasFolded: boolean;
  isAllIn: boolean;
}

export interface PokerGameState {
  gameId: string;
  communityCards: Card[]; // Flop (3), Turn (1), River (1)
  pot: string;
  currentHighBet: string;
  round: PokerBettingRound;
  activeSeat: number;
  dealerSeat: number;
  players: PokerPlayer[];
}
