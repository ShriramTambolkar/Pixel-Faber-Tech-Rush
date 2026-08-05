import { Donation } from '../models/Donation';

export const getUserImpact = async (userId: string, role: 'DONOR' | 'NGO') => {
  const matchField = role === 'DONOR' ? 'donorId' : 'requestedByNgo';
  
  const stats = await Donation.aggregate([
    { 
      $match: { 
        [matchField]: userId, 
        status: 'COLLECTED' 
      } 
    },
    {
      $group: {
        _id: null,
        totalItems: { $sum: 1 },
        totalWeightKg: { $sum: '$weightKg' }
      }
    }
  ]);

  const weight = stats[0]?.totalWeightKg || 0;
  
  return {
    itemsDonated: stats[0]?.totalItems || 0,
    wasteDivertedKg: weight,
    co2SavedKg: Number((weight * 2.5).toFixed(2))
  };
};