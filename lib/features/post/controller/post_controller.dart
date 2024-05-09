import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/repository/post_repository.dart';
import 'package:reddit/features/profile/controller/user_profile_controller.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
    postRepository: ref.read(postRepositoryProvider),
    storageRepository: ref.read(storageRepositoryProvider),
    ref: ref,
  );
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final guestPostsProvider = StreamProvider((ref) {
  return ref.watch(postControllerProvider.notifier).fetchGuestPosts();
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(postControllerProvider.notifier).getPostById(postId);
});

final getCommentOfPostProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(postControllerProvider.notifier).getCommentOfPost(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required StorageRepository storageRepository,
    required Ref ref,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required Community selectedComunity,
    required String title,
    required String description,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final post = Post(
      id: postId,
      type: "text",
      title: title,
      description: description,
      communityName: selectedComunity.name,
      communityProfilePic: selectedComunity.avatar,
      upVotes: [],
      downVotes: [],
      commentCount: 0,
      awards: [],
      userName: user.name,
      userUid: user.uid,
      createdAt: DateTime.now(),
    );

    final response = await _postRepository.addPost(post);

    state = false;

    response.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Post created successfully");
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.textPost);
        Routemaster.of(context).pop();
      },
    );
  }

  void shareLinkPost({
    required BuildContext context,
    required Community selectedComunity,
    required String title,
    required String link,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final post = Post(
      id: postId,
      type: "link",
      title: title,
      link: link,
      communityName: selectedComunity.name,
      communityProfilePic: selectedComunity.avatar,
      upVotes: [],
      downVotes: [],
      commentCount: 0,
      awards: [],
      userName: user.name,
      userUid: user.uid,
      createdAt: DateTime.now(),
    );

    final response = await _postRepository.addPost(post);
    state = false;

    response.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, "Post created successfully");
        _ref
            .read(userProfileControllerProvider.notifier)
            .updateUserKarma(UserKarma.linkPost);
        Routemaster.of(context).pop();
      },
    );
  }

  void shareImagePost({
    required BuildContext context,
    required Community selectedComunity,
    required String title,
    required File? bannerFile,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final imageLink = await _storageRepository.storeFile(
        "posts/${selectedComunity.name}", postId, bannerFile);
    imageLink.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        final post = Post(
          id: postId,
          type: "image",
          title: title,
          link: r,
          communityName: selectedComunity.name,
          communityProfilePic: selectedComunity.avatar,
          upVotes: [],
          downVotes: [],
          commentCount: 0,
          awards: [],
          userName: user.name,
          userUid: user.uid,
          createdAt: DateTime.now(),
        );

        final response = await _postRepository.addPost(post);
        state = false;

        response.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, "Post created successfully");
            _ref
                .read(userProfileControllerProvider.notifier)
                .updateUserKarma(UserKarma.imagePost);
            Routemaster.of(context).pop();
          },
        );
      },
    );
  }

  Stream<List<Post>> fetchUserCommunities(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserCommunities(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPost();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Post deleted successfully");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.deletePost);
      Routemaster.of(context).pop();
    });
  }

  void upVotes(Post post) async {
    final userUid = _ref.read(userProvider)!.uid;
    return _postRepository.upVotes(post, userUid);
  }

  void downVotes(Post post) async {
    final userUid = _ref.read(userProvider)!.uid;
    return _postRepository.downVotes(post, userUid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Post post}) async {
    final user = _ref.read(userProvider)!;
    final id = const Uuid().v1();
    Comment comment = Comment(
        id: id,
        text: text,
        postId: post.id,
        userName: user.name,
        userProfilePic: user.profilePic,
        createAt: DateTime.now());
    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Comment added");
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.comment);
    });
  }

  Stream<List<Comment>> getCommentOfPost(String postId) {
    return _postRepository.getCommentOfPost(postId);
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
