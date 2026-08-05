import mongoose, { Schema, Document } from 'mongoose';

export interface IReview extends Document {
  targetUserId: string;
  targetUserName: string;
  reviewerId: string;
  reviewerName: string;
  reviewerRole: 'DONOR' | 'NGO' | 'ADMIN';
  rating: number;
  comment?: string;
  createdAt: Date;
}

const reviewSchema = new Schema<IReview>(
  {
    targetUserId: { type: String, required: true },
    targetUserName: { type: String, required: true },
    reviewerId: { type: String, required: true },
    reviewerName: { type: String, required: true },
    reviewerRole: { type: String, enum: ['DONOR', 'NGO', 'ADMIN'], required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, default: '' },
  },
  { timestamps: true }
);

export const Review = mongoose.model<IReview>('Review', reviewSchema);
