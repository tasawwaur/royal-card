export type FriendStatus = 'pending' | 'accepted' | 'blocked';

export interface FriendRequest {
  id: string;
  userId: string;
  friendId: string;
  status: FriendStatus;
  createdAt: string;
}

export interface FriendProfile {
  userId: string;
  username: string;
  avatarUrl: string;
  level: number;
  isOnline: boolean;
  currentTableId?: string;
}
