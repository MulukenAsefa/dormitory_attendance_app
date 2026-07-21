
class AttendanceModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? roomId;
  final DateTime date;
  final DateTime? checkInTime;
  final String status; // present, absent, late, excused
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? deviceId;
  final String? deviceFingerprint;
  final String? notes;
  final String? imageUrl;
  final bool isManualEntry;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.roomId,
    required this.date,
    this.checkInTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.address,
    this.deviceId,
    this.deviceFingerprint,
    this.notes,
    this.imageUrl,
    this.isManualEntry = false,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isExcused => status == 'excused';
  bool get hasLocation => latitude != null && longitude != null;
  bool get isApproved => approvedBy != null && approvedAt != null;

  String get statusDisplayName {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'excused':
        return 'Excused';
      default:
        return 'Unknown';
    }
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      roomId: json['roomId'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime']) 
          : null,
      status: json['status'] ?? 'absent',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      deviceId: json['deviceId'],
      deviceFingerprint: json['deviceFingerprint'],
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      isManualEntry: json['isManualEntry'] ?? false,
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'roomId': roomId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'deviceId': deviceId,
      'deviceFingerprint': deviceFingerprint,
      'notes': notes,
      'imageUrl': imageUrl,
      'isManualEntry': isManualEntry,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? roomId,
    DateTime? date,
    DateTime? checkInTime,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
    String? deviceId,
    String? deviceFingerprint,
    String? notes,
    String? imageUrl,
    bool? isManualEntry,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      roomId: roomId ?? this.roomId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      deviceId: deviceId ?? this.deviceId,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      isManualEntry: isManualEntry ?? this.isManualEntry,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, userId: $userId, status: $status, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}