import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constant.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void navigateToCommunity(BuildContext context, String name) {
    Routemaster.of(context).push('/r/$name');
  }

  void navigateToCommentScreen(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  void upVote(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upVotes(post);
  }

  void downVotes(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downVotes(post);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type.toLowerCase() == "image";
    final isTypeText = post.type.toLowerCase() == "text";
    final isTypeLink = post.type.toLowerCase() == "link";
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final updownVotes = post.upVotes.length - post.downVotes.length;
    final upVotesCount = post.upVotes.length;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16)
                            .copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(
                                          context, post.communityName),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            post.communityProfilePic),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => navigateToCommunity(
                                                context, post.communityName),
                                            child: Text(
                                              "r/${post.communityName}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => navigateToProfile(
                                                context, post.userUid),
                                            child: Text(
                                              "u/${post.userName}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.userUid == user.uid)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => deletePost(context, ref),
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (post.awards.isNotEmpty) ...[
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final award = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[award]!,
                                      height: 23,
                                    );
                                  },
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title[0].toUpperCase() +
                                    post.title.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                // child: CachedNetworkImage(
                                //   imageUrl: post.title,
                                //   fit: BoxFit.cover,
                                // )
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionVertical,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Text(
                                post.description!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: currentTheme.colorScheme.background ==
                                          const Color(0xfffffbfe)
                                      ? Colors.black
                                      : const Color.fromARGB(
                                          255, 239, 218, 218),
                                  fontSize: 12,
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      onPressed:
                                          isGuest ? () {} : () => upVote(ref),
                                      icon: Icon(Constants.up,
                                          size: 25,
                                          color: post.upVotes.contains(user.uid)
                                              ? Colors.red
                                              : null),
                                    ),
                                    Text(
                                      updownVotes == 0 ? '0' : "$upVotesCount",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => downVotes(ref),
                                      icon: Icon(
                                        Constants.down,
                                        size: 25,
                                        color: post.downVotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToCommentScreen(context),
                                      icon: const Icon(
                                        Icons.comment,
                                        size: 25,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          navigateToCommentScreen(context),
                                      child: Text(
                                        post.commentCount == 0
                                            ? '0 Comments'
                                            : "${post.commentCount} Comments",
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ref
                                        .watch(getCommunityByNameProvider(
                                            post.communityName))
                                        .when(
                                          data: (data) {
                                            if (data.mods.contains(user.uid)) {
                                              return IconButton(
                                                onPressed: isGuest
                                                    ? () {}
                                                    : () => deletePost(
                                                        context, ref),
                                                icon: const Icon(
                                                  Icons.admin_panel_settings,
                                                  size: 25,
                                                ),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                          error: (error, stakeTrace) =>
                                              ErrorText(
                                                  error: error.toString()),
                                          loading: () => const Loader(),
                                        ),
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          child:
                                                              GridView.builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  gridDelegate:
                                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                                          crossAxisCount:
                                                                              4),
                                                                  itemCount: user
                                                                      .awards
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final award =
                                                                        user.awards[
                                                                            index];
                                                                    return GestureDetector(
                                                                      onTap: isGuest
                                                                          ? () {}
                                                                          : () => awardPost(
                                                                              ref,
                                                                              award,
                                                                              context),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child: Image.asset(
                                                                            Constants.awards[award]!),
                                                                      ),
                                                                    );
                                                                  }),
                                                        ),
                                                      ));
                                            },
                                      icon: const Icon(
                                          Icons.card_giftcard_outlined),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 5,
            thickness: BorderSide.strokeAlignCenter,
          ),
        ],
      ),
    );
  }
}
