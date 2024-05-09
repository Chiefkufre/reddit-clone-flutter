class Comment {
  final String id;
  final String text;
  final String postId;
  final String userName;
  final String userProfilePic;
  final DateTime createAt;
  Comment({
    required this.id,
    required this.text,
    required this.postId,
    required this.userName,
    required this.userProfilePic,
    required this.createAt,
  });

  Comment copyWith({
    String? id,
    String? text,
    String? postId,
    String? userName,
    String? userProfilePic,
    DateTime? createAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      postId: postId ?? this.postId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      createAt: createAt ?? this.createAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'postId': postId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'createAt': createAt.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      postId: map['postId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      createAt: DateTime.fromMillisecondsSinceEpoch(map['createAt']),
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, postId: $postId, userName: $userName, userProfilePic: $userProfilePic, createAt: $createAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.postId == postId &&
        other.userName == userName &&
        other.userProfilePic == userProfilePic &&
        other.createAt == createAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        postId.hashCode ^
        userName.hashCode ^
        userProfilePic.hashCode ^
        createAt.hashCode;
  }
}
