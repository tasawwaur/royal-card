export interface ChatMessage {
  id: string;
  tableId?: string;
  roomId?: string;
  senderId: string;
  senderName: string;
  messageType: 'text' | 'emoji' | 'gift';
  content: string;
  createdAt: string;
}
