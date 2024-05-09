import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screens/login_screen.dart';
import 'package:reddit/features/community/screens/add_mods_screen.dart';
import 'package:reddit/features/community/screens/community_screen.dart';
import 'package:reddit/features/community/screens/create_community_screen.dart';
import 'package:reddit/features/community/screens/edit_community_screen.dart';
import 'package:reddit/features/community/screens/mod_tools_screen.dart';
import 'package:reddit/features/home/screen/home_screen.dart';
import 'package:reddit/features/post/screens/add_post_type_screen.dart';
import 'package:reddit/features/post/screens/comment_screen.dart';
import 'package:reddit/features/profile/screens/edit_profile_screen.dart';
import 'package:reddit/features/profile/screens/user_profile.dart';

import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/r/:name/mod-tools': (route) => MaterialPage(
          child: ModToolScreen(
        name: route.pathParameters['name']!,
      )),
  '/r/:name/mod-tools/add-mods': (route) => MaterialPage(
          child: AddModsScreen(
        name: route.pathParameters['name']!,
      )),
  '/r/:name/edit-community': (route) => MaterialPage(
          child: EditCommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/u/:uid': (route) => MaterialPage(
          child: UserProfileScreen(
        uid: route.pathParameters['uid']!,
      )),
  '/u/:uid/edit': (route) => MaterialPage(
          child: EditProfileScreen(
        uid: route.pathParameters['uid']!,
      )),
  '/add-post/:type': (route) => MaterialPage(
          child: AddPostTypeScreen(
        type: route.pathParameters['type']!,
      )),
  '/post/:postId/comments': (route) => MaterialPage(
          child: CommentScreen(
        postId: route.pathParameters['postId']!,
      )),
});
