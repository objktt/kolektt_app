import 'package:flutter/cupertino.dart';

class AppVersionPage extends StatelessWidget {
  const AppVersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('앱 버전'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            '앱 버전: 1.0.0',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
