import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({
    super.key,
    required this.name,
  });

  void getCommunityByName(WidgetRef ref) {}

  void navigateToModTool(BuildContext context) {
    Routemaster.of(context).push('/r/$name/mod-tools');
  }

  void joinCommunity(BuildContext context, WidgetRef ref, uid) {
    ref
        .watch(communityControllerProvider.notifier)
        .joinCommunity(context, name, uid);
  }

  void leaveCommunity(BuildContext context, WidgetRef ref, uid) {
    ref
        .watch(communityControllerProvider.notifier)
        .leaveCommunity(context, name, uid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final community = ref.watch(getCommunityByNameProvider(name));
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      body: community.when(
        data: (community) => NestedScrollView(
          headerSliverBuilder: ((context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 150,
                floating: true,
                snap: true,
                flexibleSpace: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        community.banner,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                          radius: 30,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'r/${community.name}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isGuest)
                            community.mods.contains(user.uid)
                                ? OutlinedButton(
                                    onPressed: () {
                                      navigateToModTool(context);
                                    },
                                    child: const Text("Mod Tools"),
                                  )
                                : OutlinedButton(
                                    onPressed: () {},
                                    child: community.members.contains(user.uid)
                                        ? GestureDetector(
                                            onTap: () {
                                              leaveCommunity(
                                                  context, ref, user.uid);
                                            },
                                            child: isLoading
                                                ? const Loader()
                                                : const Text("Joined"),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              joinCommunity(
                                                  context, ref, user.uid);
                                            },
                                            child: isLoading
                                                ? const Loader()
                                                : const Text("Join"),
                                          ),
                                  )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: community.members.length > 1
                            ? Text('${community.members.length} Members')
                            : Text('${community.members.length} Member'),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          }),
          body: ref.watch(getCommunityPostProvider(community.name)).when(
                data: (data) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = data[index];
                      return PostCard(post: post);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(error: error.toString());
                },
                loading: () => const Loader(),
              ),
        ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}
