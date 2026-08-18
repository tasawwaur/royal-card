export type Suit = 'SPADES' | 'HEARTS' | 'DIAMONDS' | 'CLUBS';
export type Rank = '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K' | 'A' | 'JOKER';

export interface Card {
  suit: Suit;
  rank: Rank;
  value: number; // 2-14 (where A=14, JOKER=0)
}

export type HandType = 
  | 'TRAIL'           // Trio / Three of a kind (e.g. A-A-A)
  | 'PURE_SEQUENCE'   // Straight Flush (e.g. A-K-Q same suit)
  | 'SEQUENCE'        // Straight (e.g. 5-4-3 different suits)
  | 'COLOR'           // Flush (e.g. A-10-4 same suit)
  | 'PAIR'            // Pair (e.g. K-K-5)
  | 'HIGH_CARD';      // High card

export interface HandEvaluation {
  handType: HandType;
  rankValue: number; // For comparing hand ranks
  cards: Card[];
}
