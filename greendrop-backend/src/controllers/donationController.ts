import { Request, Response } from 'express';
import { Donation } from '../models/Donation';
import crypto from 'crypto';

export const createDonation = async (req: Request, res: Response) => {
  try {
    const { donorId, title, category, condition, weightKg, images, address, longitude, latitude } = req.body;
    const verificationCode = crypto.randomInt(100000, 999999).toString();

    const donation = await Donation.create({
      donorId,
      title,
      category,
      condition,
      weightKg,
      images,
      address: {
        formattedAddress: address,
        location: { type: 'Point', coordinates: [longitude, latitude] }
      },
      verificationCode
    });

    return res.status(201).json({ success: true, data: donation });
  } catch (err) {
    return res.status(500).json({ error: (err as Error).message });
  }
};

export const getNearbyDonations = async (req: Request, res: Response) => {
  try {
    const { lng, lat, maxDistanceKm = 10, category } = req.query;
    const query: any = { status: 'AVAILABLE' };

    if (category) query.category = category;

    if (lng && lat) {
      query['address.location'] = {
        $near: {
          $geometry: { type: 'Point', coordinates: [Number(lng), Number(lat)] },
          $maxDistance: Number(maxDistanceKm) * 1000
        }
      };
    }

    const donations = await Donation.find(query);
    return res.json({ success: true, count: donations.length, data: donations });
  } catch (err) {
    return res.status(500).json({ error: (err as Error).message });
  }
};

export const verifyPickup = async (req: Request, res: Response) => {
  try {
    const { donationId, scannedCode } = req.body;
    const donation = await Donation.findById(donationId);

    if (!donation) return res.status(404).json({ error: 'Donation not found' });
    if (donation.verificationCode !== scannedCode) {
      return res.status(400).json({ error: 'Invalid verification QR code' });
    }

    donation.status = 'COLLECTED';
    await donation.save();

    return res.json({ success: true, message: 'Pickup verified and completed' });
  } catch (err) {
    return res.status(500).json({ error: (err as Error).message });
  }
};