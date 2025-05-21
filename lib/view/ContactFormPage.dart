import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    final subject = Uri.encodeComponent('[Kolektt 문의] ${_nameController.text}');
    final body = Uri.encodeComponent(
        '이름: ${_nameController.text}\n이메일: ${_emailController.text}\n\n${_messageController.text}');
    final mailto = 'mailto:objktt.dev@gmail.com?subject=$subject&body=$body';
    if (await canLaunchUrl(Uri.parse(mailto))) {
      await launchUrl(Uri.parse(mailto));
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('메일 앱 실행 실패'),
          content:
              const Text('메일 앱을 열 수 없습니다. objktt.dev@gmail.com으로 직접 문의해 주세요.'),
          actions: [
            CupertinoDialogAction(
                child: const Text('확인'),
                onPressed: () => Navigator.pop(context))
          ],
        ),
      );
    }
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('문의하기'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: '이름',
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: '이메일',
                  keyboardType: TextInputType.emailAddress,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: _messageController,
                  placeholder: '문의 내용을 입력해 주세요',
                  maxLines: 8,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: _isSending ? null : _sendMail,
                  child: _isSending
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : const Text('문의 보내기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
