import express, { Request, Response } from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import { User } from './models/User';
import { Donation } from './models/Donation';
import { Message } from './models/Message';
import { Event } from './models/Event';
import { Report } from './models/Report';
import { NgoRequirement } from './models/NgoRequirement';
import { NgoAchievement } from './models/NgoAchievement';
import { Review } from './models/Review';

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const MONGO_URI =
  process.env.MONGO_URI ||
  'mongodb+srv://shubhamn5488_db_user:9Jujutsubanan21@greendrop.e7o1kwr.mongodb.net/greendrop?retryWrites=true&w=majority';

// 1. AUTHENTICATION & PUBLIC PROFILES
app.post('/api/auth/register', async (req: Request, res: Response) => {
  try {
    const { role, name, email, phoneNumber, ngoDetails } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ success: false, error: 'User already exists.' });

    const newUser = new User({
      role: role || 'DONOR',
      name,
      email,
      phoneNumber,
      ngoDetails: role === 'NGO' ? { ...ngoDetails, isVerified: true } : undefined,
    });

    await newUser.save();
    res.status(201).json({ success: true, data: newUser });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/auth/login', async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ success: false, error: 'Account not found.' });
    res.json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/ngo/profile/:id', async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user || user.role !== 'NGO') {
      return res.status(404).json({ success: false, error: 'NGO profile not found' });
    }
    const publicProfile = {
      id: user._id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      isVerified: user.ngoDetails?.isVerified ?? true,
      officeAddress: user.ngoDetails?.officeAddress || 'Pune NGO Office',
      description: user.ngoDetails?.description || 'Dedicated to transparent charity, relief, and community welfare.',
      websiteUrl: user.ngoDetails?.websiteUrl || 'https://smilefoundationindia.org',
      linkedinUrl: user.ngoDetails?.linkedinUrl || 'https://linkedin.com/company/smile-foundation',
      instagramUrl: user.ngoDetails?.instagramUrl || 'https://instagram.com/smilefoundationindia',
      facebookUrl: user.ngoDetails?.facebookUrl || 'https://facebook.com/smilefoundationindia',
    };
    res.json({ success: true, data: publicProfile });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.patch('/api/donor/profile', async (req: Request, res: Response) => {
  try {
    const { donorId, name, email, phoneNumber, address, profilePhotoUrl } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      donorId,
      {
        name,
        email,
        phoneNumber,
        'address.formattedAddress': address,
        profilePhotoUrl,
      },
      { new: true }
    );
    res.json({ success: true, data: updatedUser, message: 'Donor Profile updated successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.patch('/api/ngo/profile', async (req: Request, res: Response) => {
  try {
    const { ngoId, description, officeAddress, phoneNumber, websiteUrl, linkedinUrl, instagramUrl, facebookUrl, profilePhotoUrl } = req.body;
    const updateData: any = {
      phoneNumber,
      'ngoDetails.description': description,
      'ngoDetails.officeAddress': officeAddress,
      'ngoDetails.websiteUrl': websiteUrl,
      'ngoDetails.linkedinUrl': linkedinUrl,
      'ngoDetails.instagramUrl': instagramUrl,
      'ngoDetails.facebookUrl': facebookUrl,
    };
    if (profilePhotoUrl) updateData.profilePhotoUrl = profilePhotoUrl;

    const updatedUser = await User.findByIdAndUpdate(ngoId, updateData, { new: true });
    res.json({ success: true, data: updatedUser, message: 'NGO Profile updated successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// NGO ACHIEVEMENTS SHOWCASE
app.get('/api/ngo/achievements', async (req: Request, res: Response) => {
  try {
    const achievements = await NgoAchievement.find().sort({ createdAt: -1 });
    res.json({ success: true, data: achievements });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/ngo/achievements', async (req: Request, res: Response) => {
  try {
    const { ngoId, ngoName, title, description, photoUrls, impactMetrics } = req.body;
    const achievement = new NgoAchievement({
      ngoId,
      ngoName,
      title,
      description,
      photoUrls: photoUrls || [],
      impactMetrics,
    });
    await achievement.save();
    res.status(201).json({ success: true, data: achievement });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/ngo/achievements/:id', async (req: Request, res: Response) => {
  try {
    await NgoAchievement.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Achievement deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// RATINGS & REVIEWS SYSTEM
app.get('/api/reviews/:targetUserId', async (req: Request, res: Response) => {
  try {
    const reviews = await Review.find({ targetUserId: req.params.targetUserId }).sort({ createdAt: -1 });
    const count = reviews.length;
    const avg = count > 0 ? (reviews.reduce((acc, r) => acc + r.rating, 0) / count).toFixed(1) : 5.0;
    res.json({ success: true, data: reviews, averageRating: Number(avg), totalReviews: count });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/reviews', async (req: Request, res: Response) => {
  try {
    const { targetUserId, targetUserName, reviewerId, reviewerName, reviewerRole, rating, comment } = req.body;
    
    // ENFORCE RULE: Both Donors & NGOs can rate, but ONLY Donors can post written text reviews for NGOs!
    let finalComment = comment || '';
    if (reviewerRole !== 'DONOR') {
      finalComment = ''; // Strip text comment if reviewer is not a donor
    }

    const review = new Review({
      targetUserId,
      targetUserName,
      reviewerId,
      reviewerName,
      reviewerRole,
      rating: Number(rating),
      comment: finalComment,
    });
    await review.save();

    // Recompute target user's average rating
    const allReviews = await Review.find({ targetUserId });
    const count = allReviews.length;
    const avg = (allReviews.reduce((acc, r) => acc + r.rating, 0) / count).toFixed(1);
    await User.findByIdAndUpdate(targetUserId, { averageRating: Number(avg), ratingCount: count });

    res.status(201).json({ success: true, data: review, message: 'Rating/Review submitted successfully!' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});


// 2. DISASTER MODE & EMERGENCY RELIEF
app.patch('/api/ngo/disaster-mode', async (req: Request, res: Response) => {
  try {
    const { ngoId, isDisasterMode, disasterType, reason, requiredMaterials, dropoffAddress } = req.body;
    const user = await User.findByIdAndUpdate(
      ngoId,
      {
        'ngoDetails.isDisasterMode': isDisasterMode,
        'ngoDetails.disasterType': disasterType || 'Emergency Disaster',
        'ngoDetails.disasterReason': reason,
        'ngoDetails.requiredMaterials': requiredMaterials,
        'ngoDetails.dropoffAddress': dropoffAddress,
      },
      { new: true }
    );
    res.json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/disasters/active', async (req: Request, res: Response) => {
  try {
    const disasterNgos = await User.find({ 'ngoDetails.isDisasterMode': true });
    res.json({ success: true, data: disasterNgos });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. STRUCTURED NGO REQUIREMENTS BOARD
app.get('/api/ngo/requirements', async (req: Request, res: Response) => {
  try {
    const requirements = await NgoRequirement.find().sort({ createdAt: -1 });
    res.json({ success: true, data: requirements });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/ngo/requirements', async (req: Request, res: Response) => {
  try {
    const { ngoId, ngoName, itemName, quantityNeeded, urgencyLevel, targetAudience, notes } = req.body;
    const reqItem = new NgoRequirement({
      ngoId,
      ngoName,
      itemName,
      quantityNeeded,
      urgencyLevel: urgencyLevel || 'MEDIUM',
      targetAudience,
      notes,
    });
    await reqItem.save();
    res.status(201).json({ success: true, data: reqItem });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/ngo/requirements/:id', async (req: Request, res: Response) => {
  try {
    await NgoRequirement.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Requirement fulfilled/deleted' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/ngo/requirements/:id/offer-help', async (req: Request, res: Response) => {
  try {
    const { donorId, donorName, donorPhone, donorEmail, message } = req.body;
    const reqItem = await NgoRequirement.findById(req.params.id);
    if (!reqItem) return res.status(404).json({ success: false, error: 'Requirement not found' });

    reqItem.helpfulDonors.push({
      donorId,
      donorName: donorName || 'Generous Donor',
      donorPhone: donorPhone || '',
      donorEmail: donorEmail || '',
      message: message || 'I would like to help fulfill this requirement.',
      offeredAt: new Date(),
    });

    await reqItem.save();
    res.json({ success: true, data: reqItem, message: 'Offer of help sent to NGO successfully!' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 4. DONATION LIFECYCLE & QR VERIFICATION
app.post('/api/donations', async (req: Request, res: Response) => {
  try {
    const { donorId, donorName, title, category, condition, weightKg, address, photoUrls } = req.body;
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

    const newDonation = new Donation({
      donorId,
      donorName: donorName || 'Anonymous Donor',
      title,
      category,
      condition,
      weightKg,
      photoUrls: photoUrls && photoUrls.length > 0 ? photoUrls : ['https://images.unsplash.com/photo-1532629345422-7515f3d16bb0?w=500'],
      address: { formattedAddress: address, location: { type: 'Point', coordinates: [73.8567, 18.5204] } },
      verificationCode,
    });

    await newDonation.save();
    res.status(201).json({ success: true, data: newDonation });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/donations/nearby', async (req: Request, res: Response) => {
  try {
    const donations = await Donation.find().sort({ createdAt: -1 });
    res.json({ success: true, data: donations });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.patch('/api/donations/:id/request', async (req: Request, res: Response) => {
  try {
    const { ngoId, ngoName } = req.body;
    const ngoUser = await User.findById(ngoId);

    const donation = await Donation.findByIdAndUpdate(
      req.params.id,
      {
        status: 'REQUESTED',
        requestedByNgoId: ngoId,
        requestedByNgoName: ngoName,
        requestedByNgoOfficeAddress: ngoUser?.ngoDetails?.officeAddress || 'Pune NGO Main HQ',
        requestedByNgoPhone: ngoUser?.phoneNumber || '+91 9876543210',
      },
      { new: true }
    );
    res.json({ success: true, data: donation });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.patch('/api/donations/:id/accept', async (req: Request, res: Response) => {
  try {
    const donation = await Donation.findByIdAndUpdate(
      req.params.id,
      { status: 'ACCEPTED' },
      { new: true }
    );
    res.json({ success: true, data: donation });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/donations/:id/verify-collection', async (req: Request, res: Response) => {
  try {
    const { code } = req.body;
    const donation = await Donation.findById(req.params.id);
    if (!donation) return res.status(404).json({ success: false, error: 'Donation not found' });
    if (donation.verificationCode !== code) {
      return res.status(400).json({ success: false, error: 'Invalid verification code.' });
    }
    donation.status = 'COMPLETED';
    await donation.save();
    res.json({ success: true, data: donation, message: 'Collection verified & completed!' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put('/api/donations/:id', async (req: Request, res: Response) => {
  try {
    const donation = await Donation.findById(req.params.id);
    if (!donation) return res.status(404).json({ success: false, error: 'Donation not found' });

    const diffInMinutes = (new Date().getTime() - new Date(donation.createdAt).getTime()) / (1000 * 60);
    if (diffInMinutes > 5) {
      return res.status(403).json({ success: false, error: 'Edit window expired (5 min limit).' });
    }

    const updated = await Donation.findByIdAndUpdate(
      req.params.id,
      { title: req.body.title, weightKg: req.body.weightKg },
      { new: true }
    );
    res.json({ success: true, data: updated });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/donations/:id', async (req: Request, res: Response) => {
  try {
    await Donation.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 5. NGO CAMPAIGNS & CANCELLATIONS
app.get('/api/events', async (req: Request, res: Response) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });
    res.json({ success: true, data: events });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/events', async (req: Request, res: Response) => {
  try {
    const { ngoId, ngoName, title, description, bannerPhotoUrl, address, googleMapsUrl, targetItems, eventDate, eventTime, eventDays } = req.body;
    const newEvent = new Event({
      ngoId,
      ngoName,
      title,
      description,
      bannerPhotoUrl: bannerPhotoUrl || 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=500',
      address,
      googleMapsUrl: googleMapsUrl || 'https://maps.google.com/?q=18.5204,73.8567',
      targetItems,
      eventDate: eventDate || '2026-08-15',
      eventTime: eventTime || '10:00 AM - 4:00 PM',
      eventDays: eventDays || 'Saturday & Sunday',
      status: 'ACTIVE',
    });
    await newEvent.save();
    res.status(201).json({ success: true, data: newEvent });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/events/:id', async (req: Request, res: Response) => {
  try {
    await Event.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Event cancelled & deleted successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 6. REPORT SYSTEM & ADMIN MODERATION
app.post('/api/reports', async (req: Request, res: Response) => {
  try {
    const { reportedByUserId, reportedByUserName, targetUserId, targetUserName, reportCategory, reason, itemOrEventTitle } = req.body;
    const newReport = new Report({
      reportedByUserId,
      reportedByUserName,
      targetUserId,
      targetUserName,
      reportCategory,
      reason,
      itemOrEventTitle,
    });
    await newReport.save();
    res.status(201).json({ success: true, data: newReport });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/admin/reports', async (req: Request, res: Response) => {
  try {
    const reports = await Report.find().sort({ createdAt: -1 });
    res.json({ success: true, data: reports });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/admin/warn-user', async (req: Request, res: Response) => {
  try {
    const { userId, reason } = req.body;
    const user = await User.findByIdAndUpdate(
      userId,
      { $inc: { warningCount: 1 }, $set: { lastWarningReason: reason } },
      { new: true }
    );
    res.json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/api/admin/users', async (req: Request, res: Response) => {
  try {
    const users = await User.find().sort({ createdAt: -1 });
    res.json({ success: true, data: users });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.delete('/api/admin/users/:id', async (req: Request, res: Response) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'User removed by admin' });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 7. MESSAGING / CHAT API
app.get('/api/chat/:donationId', async (req: Request, res: Response) => {
  try {
    const messages = await Message.find({ donationId: req.params.donationId }).sort({ createdAt: 1 });
    res.json({ success: true, data: messages });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/chat', async (req: Request, res: Response) => {
  try {
    const { donationId, senderId, receiverId, text } = req.body;
    const newMessage = new Message({ donationId, senderId, receiverId, text });
    await newMessage.save();
    res.status(201).json({ success: true, data: newMessage });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = 5000;
mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log('MongoDB Connected successfully');
    app.listen(PORT, () => console.log(`GreenDrop Server running on http://localhost:${PORT}`));
  })
  .catch((err) => console.error('MongoDB error:', err));