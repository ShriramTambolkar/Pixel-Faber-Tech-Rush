import mongoose, { Schema, Document } from 'mongoose';

export interface INgoAchievement extends Document {
  ngoId: string;
  ngoName: string;
  title: string;
  description: string;
  photoUrls: string[];
  impactMetrics?: string;
  createdAt: Date;
}

const ngoAchievementSchema = new Schema<INgoAchievement>(
  {
    ngoId: { type: String, required: true },
    ngoName: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    photoUrls: [{ type: String }],
    impactMetrics: { type: String, default: '' },
  },
  { timestamps: true }
);

export const NgoAchievement = mongoose.model<INgoAchievement>(
  'NgoAchievement',
  ngoAchievementSchema
);
