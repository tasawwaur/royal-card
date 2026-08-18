import { Card, HandType } from './cards';

export type GameStatus = 'in_progress' | 'completed' | 'aborted';
export type PlayerActionType = 'boot' | 'pack' | 'chaal' | 'raise' | 'see_cards' | 'sideshow_request' | 'sideshow_response' | 'show';

export interface GamePlayerState {
  userId: string;
  username: string;
  avatarUrl: string;
  seatIndex: number;
  chipsBalance: string;
  isBlind: boolean;
  hasSeenCards: boolean;
  hasFolded: boolean;
  totalBetAmount: string;
  cards?: Card[]; // Sanitized server-side: populated ONLY for self if seen, or for all players after show
}

export interface GameState {
  gameId: string;
  tableId: string;
  roundNumber: number;
  bootAmount: string;
  totalPot: string;
  currentBet: string;
  currentTurnSeat: number;
  status: GameStatus;
  players: GamePlayerState[];
  winnerUserId?: string;
  winningHandType?: HandType;
}
