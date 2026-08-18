export type AuthProvider = 'guest' | 'phone' | 'google' | 'facebook';

export interface User {
  id: string;
  phoneNumber?: string;
  email?: string;
  authProvider: AuthProvider;
  providerId?: string;
  isActive: boolean;
  isBanned: boolean;
  createdAt: string;
}

export interface JWTPayload {
  userId: string;
  authProvider: AuthProvider;
  iat?: number;
  exp?: number;
}
