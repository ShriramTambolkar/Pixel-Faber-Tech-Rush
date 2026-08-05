class ReportModel {
  final String id;
  final String reportedByUserId;
  final String reportedByUserName;
  final String targetUserId;
  final String targetUserName;
  final String reportCategory;
  final String reason;
  final String itemOrEventTitle;

  ReportModel({
    required this.id,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.targetUserId,
    required this.targetUserName,
    required this.reportCategory,
    required this.reason,
    required this.itemOrEventTitle,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] ?? '',
      reportedByUserId: json['reportedByUserId'] ?? '',
      reportedByUserName: json['reportedByUserName'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      targetUserName: json['targetUserName'] ?? '',
      reportCategory: json['reportCategory'] ?? '',
      reason: json['reason'] ?? '',
      itemOrEventTitle: json['itemOrEventTitle'] ?? '',
    );
  }
}
