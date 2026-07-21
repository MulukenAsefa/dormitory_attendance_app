class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // student, manager, admin
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? roomId;
  final String? deviceId;
  final bool isActive;
  final bool isEmailVerified;
  final bool isDeviceRegistered;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.roomId,
    this.deviceId,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isDeviceRegistered = false,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isStudent => role == 'student';
  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'student',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      roomId: json['roomId'],
      deviceId: json['deviceId'],
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isDeviceRegistered: json['isDeviceRegistered'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'roomId': roomId,
      'deviceId': deviceId,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isDeviceRegistered': isDeviceRegistered,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    String? roomId,
    String? deviceId,
    bool? isActive,
    bool? isEmailVerified,
    bool? isDeviceRegistered,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      roomId: roomId ?? this.roomId,
      deviceId: deviceId ?? this.deviceId,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isDeviceRegistered: isDeviceRegistered ?? this.isDeviceRegistered,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}