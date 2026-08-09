import 'dart:async';
import 'package:flutter/foundation.dart';

class CourierDispatchResult {
  final bool success;
  final String trackingId;
  final String provider;
  final String estimatedArrival;
  final String courierName;
  final String courierPhone;

  CourierDispatchResult({
    required this.success,
    required this.trackingId,
    required this.provider,
    required this.estimatedArrival,
    required this.courierName,
    required this.courierPhone,
  });
}

class CourierService {
  static Future<CourierDispatchResult> dispatchCourier({
    required String pickupAddress,
    required String dropoffAddress,
    required String providerName, // 'Porter' or 'Uber Connect'
  }) async {
    // Simulate API webhook call to Porter / Uber Connect API
    await Future.delayed(const Duration(milliseconds: 1200));

    final trackingId = 'TRK_${providerName.toUpperCase().substring(0, 3)}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    debugPrint('🚚 Webhook triggered: Dispatched $providerName pickup from $pickupAddress to $dropoffAddress ($trackingId)');

    return CourierDispatchResult(
      success: true,
      trackingId: trackingId,
      provider: providerName,
      estimatedArrival: '12-18 Mins',
      courierName: providerName == 'Porter' ? 'Ramesh Kumar (Porter Mini)' : 'Suresh Sharma (Uber Connect)',
      courierPhone: '+91 9876543210',
    );
  }
}
