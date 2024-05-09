import 'dart:convert';
import 'package:flutter/widgets.dart';

class Post {
  final String id;
  final String type;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> upVotes;
  final List<String> downVotes;
  final int commentCount;
  final List<String> awards;
  final String userName;
  final String userUid;
  final DateTime createdAt;
  Post({
    required this.id,
    required this.type,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.upVotes,
    required this.downVotes,
    required this.commentCount,
    required this.awards,
    required this.userName,
    required this.userUid,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    String? type,
    String? title,
    ValueGetter<String?>? link,
    ValueGetter<String?>? description,
    String? communityName,
    String? communityProfilePic,
    List<String>? upVotes,
    List<String>? downVotes,
    int? commentCount,
    List<String>? awards,
    String? userName,
    String? userUid,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      link: link != null ? link() : this.link,
      description: description != null ? description() : this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      commentCount: commentCount ?? this.commentCount,
      awards: awards ?? this.awards,
      userName: userName ?? this.userName,
      userUid: userUid ?? this.userUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'link': link,
      'description': description,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'commentCount': commentCount,
      'awards': awards,
      'userName': userName,
      'userUid': userUid,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      communityName: map['communityName'] ?? '',
      communityProfilePic: map['communityProfilePic'] ?? '',
      upVotes: List<String>.from(map['upVotes']),
      downVotes: List<String>.from(map['downVotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      awards: List<String>.from(map['awards']),
      userName: map['userName'] ?? '',
      userUid: map['userUid'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Post(id: $id, type: $type, title: $title, link: $link, description: $description, communityName: $communityName, communityProfilePic: $communityProfilePic, upVotes: $upVotes, downVotes: $downVotes, commentCount: $commentCount, awards: $awards, userName: $userName, userUid: $userUid, createdAt: $createdAt)';
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   final listEquals = const DeepCollectionEquality().equals;

  //   return other is Post &&
  //     other.id == id &&
  //     other.type == type &&
  //     other.title == title &&
  //     other.link == link &&
  //     other.description == description &&
  //     other.communityName == communityName &&
  //     other.communityProfilePic == communityProfilePic &&
  //     listEquals(other.upVotes, upVotes) &&
  //     listEquals(other.downVotes, downVotes) &&
  //     other.commentCount == commentCount &&
  //     listEquals(other.awards, awards) &&
  //     other.userName == userName &&
  //     other.userUid == userUid &&
  //     other.createdAt == createdAt;
  // }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        communityName.hashCode ^
        communityProfilePic.hashCode ^
        upVotes.hashCode ^
        downVotes.hashCode ^
        commentCount.hashCode ^
        awards.hashCode ^
        userName.hashCode ^
        userUid.hashCode ^
        createdAt.hashCode;
  }
}
