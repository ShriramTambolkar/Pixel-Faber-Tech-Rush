"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserImpact = void 0;
const Donation_1 = require("../models/Donation");
const getUserImpact = async (userId, role) => {
    const matchField = role === 'DONOR' ? 'donorId' : 'requestedByNgo';
    const stats = await Donation_1.Donation.aggregate([
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
exports.getUserImpact = getUserImpact;
