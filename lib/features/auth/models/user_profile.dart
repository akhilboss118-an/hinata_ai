/// User profile entity synchronized across devices via Firestore /users/{uid}
class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  final String timezone;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastSeenAt,
    required this.timezone,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    String? timezone,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'timezone': timezone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      try {
        // Handle Firestore Timestamp dynamically
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return UserProfile(
      uid: uid,
      displayName: map['displayName'] as String? ?? 'Friend',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? map['photoURL'] as String?,
      createdAt: parseDate(map['createdAt']),
      lastSeenAt: parseDate(map['lastSeenAt'] ?? map['lastLoginAt']),
      timezone: map['timezone'] as String? ?? DateTime.now().timeZoneName,
    );
  }
}
