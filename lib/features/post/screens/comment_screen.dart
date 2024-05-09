import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/post/widget/comment_card.dart';
import 'package:reddit/models/post_model.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  void addComment(Post post) {
    ref.watch(postControllerProvider.notifier).addComment(
          context: context,
          text: _commentController.text.trim(),
          post: post,
        );
    setState(() {
      _commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        title: const Text('comments'),
      ),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(
                    post: data,
                  ),
                  if (!isGuest)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: TextField(
                        onSubmitted: (val) => addComment(data),
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: "Add a comment",
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ref.watch(getCommentOfPostProvider(widget.postId)).when(
                        data: (data) {
                          print(data.isEmpty);
                          return Expanded(
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, int index) {
                                  final comment = data[index];
                                  return CommentCard(
                                    comment: comment,
                                  );
                                }),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
