import 'package:flutter/foundation.dart';

class UserModel {
  final String uid;
  final String name;
  final String profilePic;
  final String banner;
  final int karma;
  final bool isAuthenticated;
  final List<String> awards;

  UserModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.karma,
    required this.isAuthenticated,
    required this.awards,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? profilePic,
    String? banner,
    int? karma,
    bool? isAuthenticated,
    List<String>? awards,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      karma: karma ?? this.karma,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'karma': karma,
      'isAuthenticated': isAuthenticated,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      banner: map['banner'] ?? '',
      karma: map['karma']?.toInt() ?? 0,
      isAuthenticated: map['isAuthenticated'] ?? false,
      awards: List<String>.from(map['awards']),
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, profilePic: $profilePic, banner: $banner, karma: $karma, isAuthenticated: $isAuthenticated, awards: $awards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.karma == karma &&
        other.isAuthenticated == isAuthenticated &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        karma.hashCode ^
        isAuthenticated.hashCode ^
        awards.hashCode;
  }
}
