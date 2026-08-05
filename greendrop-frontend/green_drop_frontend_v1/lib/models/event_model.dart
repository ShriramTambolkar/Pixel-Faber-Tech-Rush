class EventModel {
  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final String eventDateTime;
  final String address;
  final String targetItems;
  final String bannerPhotoUrl;

  EventModel({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    required this.eventDateTime,
    required this.address,
    required this.targetItems,
    required this.bannerPhotoUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? '',
      ngoId: json['ngoId'] ?? '',
      ngoName: json['ngoName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventDateTime: json['eventDateTime'] ?? '',
      address: json['address'] ?? '',
      targetItems: json['targetItems'] ?? '',
      bannerPhotoUrl: json['bannerPhotoUrl'] ?? '',
    );
  }
}
