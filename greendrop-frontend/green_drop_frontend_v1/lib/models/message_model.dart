class MessageModel {
  final String id;
  final String donationId;
  final String senderId;
  final String recipientId;
  final String text;
  final String? timestamp;

  MessageModel({
    required this.id,
    required this.donationId,
    required this.senderId,
    required this.recipientId,
    required this.text,
    this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      donationId: json['donationId'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}
