import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'genre_select_page.dart';

class IdSetupPage extends StatefulWidget {
  const IdSetupPage({super.key});

  @override
  State<IdSetupPage> createState() => _IdSetupPageState();
}

class _IdSetupPageState extends State<IdSetupPage> {
  final TextEditingController _idController = TextEditingController();
  bool _isIdValid = false;
  bool _isChecking = false;
  bool _isDuplicated = false;
  String? _errorText;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _validateId(String value) {
    // 영문, 숫자 2~16자
    final valid = RegExp(r'^[a-zA-Z0-9]{2,16}\$').hasMatch(value);
    setState(() {
      _isIdValid = valid;
      _errorText = valid ? null : '2~16자의 영문 또는 숫자만 입력하세요.';
      _isDuplicated = false;
    });
  }

  Future<void> _checkDuplicate() async {
    setState(() {
      _isChecking = true;
      _errorText = null;
    });
    await Future.delayed(const Duration(seconds: 1)); // TODO: 실제 중복확인 API 연동
    setState(() {
      _isChecking = false;
      _isDuplicated = false; // TODO: 중복이면 true
      _errorText = _isDuplicated ? '이미 사용 중인 아이디입니다.' : null;
    });
  }

  void _onNext() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const GenreSelectPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    const Color borderColor = Color(0xFFE0E0E5);
    const Color errorColor = Color(0xFFFF3B30);
    final Color backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );
    final Color textColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '아이디 설정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '사용하실 아이디(닉네임)를\n입력해주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  height: 36 / 28,
                ),
              ),
              const SizedBox(height: 32),
              CupertinoTextField(
                controller: _idController,
                placeholder: '아이디(닉네임) 입력',
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFB0B0B8),
                  fontSize: 16,
                ),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: textColor,
                  fontSize: 16,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _errorText != null ? errorColor : borderColor,
                    width: 1.5,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(16),
                ],
                onChanged: _validateId,
                onSubmitted: (_) => _validateId(_idController.text),
                textInputAction: TextInputAction.done,
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: _isIdValid ? primaryColor : borderColor,
                      borderRadius: BorderRadius.circular(8),
                      onPressed:
                          _isIdValid && !_isChecking ? _checkDuplicate : null,
                      child: _isChecking
                          ? const CupertinoActivityIndicator(radius: 10)
                          : const Text(
                              '중복확인',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_errorText != null)
                    Flexible(
                      child: Text(
                        _errorText!,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: errorColor,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (_isIdValid && !_isDuplicated && _errorText == null)
                    const Flexible(
                      child: Text(
                        '사용 가능한 아이디입니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color(0xFF22C55E),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  onPressed: _onNext,
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: CupertinoColors.white,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
