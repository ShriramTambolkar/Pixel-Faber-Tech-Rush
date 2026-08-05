import mongoose, { Schema, Document } from 'mongoose';

export interface IEvent extends Document {
  ngoId: string;
  ngoName: string;
  title: string;
  description: string;
  bannerPhotoUrl: string;
  address: string;
  googleMapsUrl: string;
  targetItems: string;
  eventDate: string;
  eventTime: string;
  eventDays: string;
  status: 'ACTIVE' | 'CANCELLED';
  createdAt: Date;
}

const eventSchema = new Schema<IEvent>(
  {
    ngoId: { type: String, required: true },
    ngoName: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    bannerPhotoUrl: { type: String, required: true },
    address: { type: String, required: true },
    googleMapsUrl: { type: String, default: '' },
    targetItems: { type: String, required: true },
    eventDate: { type: String, required: true },
    eventTime: { type: String, required: true },
    eventDays: { type: String, required: true },
    status: { type: String, enum: ['ACTIVE', 'CANCELLED'], default: 'ACTIVE' },
  },
  { timestamps: true }
);

export const Event = mongoose.model<IEvent>('Event', eventSchema);