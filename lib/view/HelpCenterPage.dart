import 'package:flutter/cupertino.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('고객센터'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            '문의사항이 있으시면 support@kolektt.com 으로 연락주세요.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
