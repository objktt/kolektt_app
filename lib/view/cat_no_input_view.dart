import 'package:flutter/cupertino.dart';

class CatNoInputView extends StatefulWidget {
  final Function(String) onSubmit;
  const CatNoInputView({super.key, required this.onSubmit});
  @override
  _CatNoInputViewState createState() => _CatNoInputViewState();
}

class _CatNoInputViewState extends State<CatNoInputView> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text("CatNo로 검색"),
      content: Column(
        children: [
          const Text("앨범의 CatNo를 입력해주세요"),
          CupertinoTextField(
            controller: _controller,
            placeholder: "예시: 88985456371, SRCS-9198",
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text("취소"),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          child: const Text("검색"),
          onPressed: () {
            widget.onSubmit(_controller.text);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}