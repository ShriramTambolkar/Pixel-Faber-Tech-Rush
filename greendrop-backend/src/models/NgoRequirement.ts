import mongoose, { Schema, Document } from 'mongoose';

export interface IHelpfulDonor {
  donorId: string;
  donorName: string;
  donorPhone?: string;
  donorEmail?: string;
  message?: string;
  offeredAt?: Date;
}

export interface INgoRequirement extends Document {
  ngoId: string;
  ngoName: string;
  itemName: string;
  quantityNeeded: string;
  urgencyLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  targetAudience: string;
  notes?: string;
  helpfulDonors: IHelpfulDonor[];
  createdAt: Date;
}

const ngoRequirementSchema = new Schema<INgoRequirement>(
  {
    ngoId: { type: String, required: true },
    ngoName: { type: String, required: true },
    itemName: { type: String, required: true },
    quantityNeeded: { type: String, required: true },
    urgencyLevel: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      default: 'MEDIUM',
    },
    targetAudience: { type: String, required: true },
    notes: { type: String, default: '' },
    helpfulDonors: [
      {
        donorId: { type: String, required: true },
        donorName: { type: String, required: true },
        donorPhone: { type: String, default: '' },
        donorEmail: { type: String, default: '' },
        message: { type: String, default: '' },
        offeredAt: { type: Date, default: Date.now },
      },
    ],
  },
  { timestamps: true }
);

export const NgoRequirement = mongoose.model<INgoRequirement>(
  'NgoRequirement',
  ngoRequirementSchema
);
