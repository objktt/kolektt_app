import 'package:flutter/cupertino.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('앱 정보'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Kolektt는 나만의 레코드 컬렉션을 관리하는 앱입니다.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
