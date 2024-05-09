import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallet.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerStatefulWidget {
  const ProfileDrawer({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileDrawer();
}

class _ProfileDrawer extends ConsumerState<ProfileDrawer> {
  void navigateToProfile(uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      width: 250,
      // backgroundColor: Pallete.lightModeAppTheme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
                radius: 60,
              ),
              const SizedBox(height: 20),
              Text(
                "u/${user.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              ListTile(
                title: const Text("Profile"),
                leading: const Icon(Icons.person),
                onTap: () => navigateToProfile(user.uid),
              ),
              ListTile(
                title: const Text("Logout"),
                leading: Icon(
                  Icons.logout,
                  color: Pallete.redColor,
                ),
                onTap: () => logOut(ref),
              ),
              Switch.adaptive(
                value: ref.read(themeNotifierProvider.notifier).mode ==
                    ThemeMode.dark,
                onChanged: (val) => toggleTheme(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
