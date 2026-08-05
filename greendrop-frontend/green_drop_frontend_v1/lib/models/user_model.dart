class NgoDetails {
  final String? darpanId;
  final String? registrationCertificateUrl;
  final String? panCardUrl;
  final String? officeAddress;

  NgoDetails({
    this.darpanId,
    this.registrationCertificateUrl,
    this.panCardUrl,
    this.officeAddress,
  });

  factory NgoDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NgoDetails();
    return NgoDetails(
      darpanId: json['darpanId'],
      registrationCertificateUrl: json['registrationCertificateUrl'],
      panCardUrl: json['panCardUrl'],
      officeAddress: json['officeAddress'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (darpanId != null) 'darpanId': darpanId,
        if (registrationCertificateUrl != null)
          'registrationCertificateUrl': registrationCertificateUrl,
        if (panCardUrl != null) 'panCardUrl': panCardUrl,
        if (officeAddress != null) 'officeAddress': officeAddress,
      };
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final int warningCount;
  final String? lastWarningReason;
  final NgoDetails? ngoDetails;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.warningCount = 0,
    this.lastWarningReason,
    this.ngoDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'DONOR',
      phoneNumber: json['phoneNumber'],
      warningCount: json['warningCount'] ?? 0,
      lastWarningReason: json['lastWarningReason'],
      ngoDetails: json['ngoDetails'] != null
          ? NgoDetails.fromJson(json['ngoDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'name': name,
        'role': role,
        'phoneNumber': phoneNumber,
        'warningCount': warningCount,
        'lastWarningReason': lastWarningReason,
        if (ngoDetails != null) 'ngoDetails': ngoDetails!.toJson(),
      };
}
