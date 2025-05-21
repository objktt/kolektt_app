import 'package:flutter/cupertino.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../view_models/auth_vm.dart';
import 'package:kolektt/view/AppInfoPage.dart';
import 'package:kolektt/view/ContactFormPage.dart';
import 'package:kolektt/view/PrivacyPolicyPage.dart';
import 'package:kolektt/view/TermsPage.dart';
import 'package:kolektt/view/AppVersionPage.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('설정'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildListItem(
                    context,
                    icon: const Icon(
                      CupertinoIcons.circle_grid_hex,
                      color: CupertinoColors.black,
                    ),
                    title: '앱 정보',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const AppInfoPage()));
                    },
                  ),
                  _buildListItem(
                    context,
                    icon: const Icon(
                      CupertinoIcons.question_circle,
                      color: CupertinoColors.black,
                    ),
                    title: '문의하기',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const ContactFormPage()));
                    },
                  ),
                  _buildListItem(
                    context,
                    icon: const Icon(
                      CupertinoIcons.shield,
                      color: CupertinoColors.black,
                    ),
                    title: '개인정보 처리방침',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const PrivacyPolicyPage()));
                    },
                  ),
                  _buildListItem(
                    context,
                    icon: const Icon(
                      CupertinoIcons.doc_text,
                      color: CupertinoColors.black,
                    ),
                    title: '이용약관',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const TermsPage()));
                    },
                  ),
                  _buildListItem(
                    context,
                    icon: const Icon(
                      CupertinoIcons.info_circle,
                      color: CupertinoColors.black,
                    ),
                    title: '앱 버전',
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => const AppVersionPage()));
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: CupertinoButton(
                onPressed: () async {
                  final auth = context.read<AuthViewModel>();
                  await auth.signOut();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    CupertinoPageRoute(
                        builder: (context) => const AuthenticationWrapper()),
                    (route) => false, // 모든 이전 라우트를 제거합니다.
                  );
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: CupertinoColors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context,
      {required Icon icon,
      required String title,
      required VoidCallback? onPressed}) {
    return SizedBox(
      height: 64,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 16.0),
              child: icon,
            ),
            Expanded(
              child: Text(
                title,
                style: const FigmaTextStyles()
                    .bodymd
                    .copyWith(color: FigmaColors.socialappleprimary),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
