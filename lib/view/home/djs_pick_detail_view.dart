import 'package:flutter/cupertino.dart';

import '../../components/dj_content_section.dart';
import '../../components/dj_profile_header.dart';
import '../../model/dj.dart';


// 메인 뷰
class DJsPickDetailView extends StatelessWidget {
  final DJ dj;

  const DJsPickDetailView({super.key, required this.dj});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Kolektt',
        middle: Text('DJ 상세'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DJProfileHeader(dj: dj),
              ...dj.interviewContents
                  .map((content) => DJContentSection(content: content))
                  ,
            ],
          ),
        ),
      ),
    );
  }
}

