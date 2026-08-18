export interface Room {
  id: string;
  createdBy?: string;
  roomCode?: string;
  roomName: string;
  isPrivate: boolean;
  maxPlayers: number;
  bootAmount: string;
  chaalLimit: string;
  potLimit: string;
  status: 'active' | 'closed';
}

export interface Table {
  id: string;
  roomId: string;
  serverId: string;
  status: 'waiting' | 'playing' | 'closed';
  currentDealerSeat: number;
}
