import 'package:flutter/cupertino.dart';

import '../main.dart';
import 'home/kolektt_home_screen.dart';
import 'profile/profile_view.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.95),
        activeColor: primaryColor,
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: "프로필",
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const KolekttHomeScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const ProfileView(),
            );
          default:
            return Container();
        }
      },
    );
  }
}
