"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyPickup = exports.getNearbyDonations = exports.createDonation = void 0;
const Donation_1 = require("../models/Donation");
const crypto_1 = __importDefault(require("crypto"));
const createDonation = async (req, res) => {
    try {
        const { donorId, title, category, condition, weightKg, images, address, longitude, latitude } = req.body;
        const verificationCode = crypto_1.default.randomInt(100000, 999999).toString();
        const donation = await Donation_1.Donation.create({
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
    }
    catch (err) {
        return res.status(500).json({ error: err.message });
    }
};
exports.createDonation = createDonation;
const getNearbyDonations = async (req, res) => {
    try {
        const { lng, lat, maxDistanceKm = 10, category } = req.query;
        const query = { status: 'AVAILABLE' };
        if (category)
            query.category = category;
        if (lng && lat) {
            query['address.location'] = {
                $near: {
                    $geometry: { type: 'Point', coordinates: [Number(lng), Number(lat)] },
                    $maxDistance: Number(maxDistanceKm) * 1000
                }
            };
        }
        const donations = await Donation_1.Donation.find(query);
        return res.json({ success: true, count: donations.length, data: donations });
    }
    catch (err) {
        return res.status(500).json({ error: err.message });
    }
};
exports.getNearbyDonations = getNearbyDonations;
const verifyPickup = async (req, res) => {
    try {
        const { donationId, scannedCode } = req.body;
        const donation = await Donation_1.Donation.findById(donationId);
        if (!donation)
            return res.status(404).json({ error: 'Donation not found' });
        if (donation.verificationCode !== scannedCode) {
            return res.status(400).json({ error: 'Invalid verification QR code' });
        }
        donation.status = 'COLLECTED';
        await donation.save();
        return res.json({ success: true, message: 'Pickup verified and completed' });
    }
    catch (err) {
        return res.status(500).json({ error: err.message });
    }
};
exports.verifyPickup = verifyPickup;
