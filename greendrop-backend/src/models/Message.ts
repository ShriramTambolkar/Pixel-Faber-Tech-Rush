import mongoose, { Schema, Document } from 'mongoose';

export interface IMessage extends Document {
  donationId: string;
  senderId: string;
  receiverId: string;
  text: string;
}

const messageSchema = new Schema<IMessage>(
  {
    donationId: { type: String, required: true },
    senderId: { type: String, required: true },
    receiverId: { type: String, required: true },
    text: { type: String, required: true },
  },
  { timestamps: true }
);

export const Message = mongoose.model<IMessage>('Message', messageSchema);