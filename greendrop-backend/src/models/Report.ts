import mongoose, { Schema, Document } from 'mongoose';

export interface IReport extends Document {
  reportedByUserId: string;
  reportedByUserName: string;
  targetUserId: string;
  targetUserName: string;
  reportCategory: string;
  reason: string;
  itemOrEventTitle: string;
  status: 'PENDING' | 'WARNED' | 'DISMISSED';
  createdAt: Date;
}

const reportSchema = new Schema<IReport>(
  {
    reportedByUserId: { type: String, required: true },
    reportedByUserName: { type: String, required: true },
    targetUserId: { type: String, required: true },
    targetUserName: { type: String, required: true },
    reportCategory: { type: String, required: true },
    reason: { type: String, required: true },
    itemOrEventTitle: { type: String, required: true },
    status: { type: String, enum: ['PENDING', 'WARNED', 'DISMISSED'], default: 'PENDING' },
  },
  { timestamps: true }
);

export const Report = mongoose.model<IReport>('Report', reportSchema);