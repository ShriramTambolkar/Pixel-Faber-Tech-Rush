class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String title;
  final String category;
  final String condition;
  final double weightKg;
  final String verificationCode;
  final String status;
  final List<String> photoUrls;
  final Map<String, dynamic>? address;
  final String? requestedByNgoId;
  final String? requestedByNgoName;
  final String? requestedByNgoOfficeAddress;
  final String? createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.category,
    required this.condition,
    required this.weightKg,
    required this.verificationCode,
    required this.status,
    required this.photoUrls,
    this.address,
    this.requestedByNgoId,
    this.requestedByNgoName,
    this.requestedByNgoOfficeAddress,
    this.createdAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['_id'] ?? '',
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      condition: json['condition'] ?? 'Good',
      weightKg: (json['weightKg'] ?? 1).toDouble(),
      verificationCode: json['verificationCode'] ?? '',
      status: json['status'] ?? 'AVAILABLE',
      photoUrls: json['photoUrls'] != null ? List<String>.from(json['photoUrls']) : [],
      address: json['address'] is Map<String, dynamic> ? json['address'] : null,
      requestedByNgoId: json['requestedByNgoId'],
      requestedByNgoName: json['requestedByNgoName'],
      requestedByNgoOfficeAddress: json['requestedByNgoOfficeAddress'],
      createdAt: json['createdAt'],
    );
  }
}
