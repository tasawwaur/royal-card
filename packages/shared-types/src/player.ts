export interface PlayerProfile {
  userId: string;
  username: string;
  avatarUrl: string;
  level: number;
  xp: number;
  totalGamesPlayed: number;
  totalGamesWon: number;
  totalChipsWon: string;
  biggestPotWon: string;
}

export interface Wallet {
  userId: string;
  chipsBalance: string;
  gemsBalance: number;
  version: number;
}
