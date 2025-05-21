import 'package:flutter/cupertino.dart';
import '../login_view.dart';
import 'terms_agreement_page.dart';
import '../../view_models/auth_vm.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    const Color titleColor = Color(0xFF0E0E10);
    const Color descColor = Color(0xFF575758);
    const Color borderColor = Color(0xFFB7B7B8);
    const Color helpTextColor = Color(0xFF868687);
    const Color backgroundColor = CupertinoColors.white;
    const Color loginLinkColor = Color(0xFF0036FF);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // 타이틀
                const Text(
                  '회원가입',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                    color: Color(0xFF0E0E10),
                    height: 44 / 32,
                  ),
                ),
                const SizedBox(height: 40),
                // 이메일
                const Text(
                  '이메일',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF575758),
                    letterSpacing: 0.56,
                    height: 24 / 14,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: '이메일을 입력해 주세요.',
                  placeholderStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFB7B7B8),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                // 비밀번호
                const Text(
                  '비밀번호',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF575758),
                    letterSpacing: 0.56,
                    height: 24 / 14,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: '비밀번호를 입력해주세요',
                  placeholderStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFB7B7B8),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  obscureText: _obscurePassword,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 20,
                        color: descColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '영문, 숫자, 특수문자 조합 8-20자',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF868687),
                    height: 22 / 12,
                  ),
                ),
                const SizedBox(height: 24),
                // 비밀번호 확인
                const Text(
                  '비밀번호 확인',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF575758),
                    letterSpacing: 0.56,
                    height: 24 / 14,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoTextField(
                  controller: _passwordConfirmController,
                  placeholder: '비밀번호를 다시 입력해주세요',
                  placeholderStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFB7B7B8),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  obscureText: _obscurePasswordConfirm,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => setState(() =>
                          _obscurePasswordConfirm = !_obscurePasswordConfirm),
                      child: Icon(
                        _obscurePasswordConfirm
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 20,
                        color: descColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '영문, 숫자, 특수문자 조합 8-20자',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF868687),
                    height: 22 / 12,
                  ),
                ),
                const SizedBox(height: 32),
                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CupertinoButton(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: 회원가입 처리
                    },
                    child: const Text(
                      '확인',
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
                // 또는 다음으로 계속하기 구분선
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '또는 다음으로 계속하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF868687),
                          letterSpacing: 0.56,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // SSO 버튼 (구글)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFE0E0E5), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(8),
                    color: CupertinoColors.white,
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            try {
                              final authVM = context.read<AuthViewModel>();
                              await authVM.signInWithGoogle();
                              if (authVM.errorMessage == null && mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) =>
                                          const TermsAgreementPage()),
                                  (route) => false,
                                );
                              } else if (authVM.errorMessage != null) {
                                setState(() {
                                  _errorMessage = authVM.errorMessage;
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _errorMessage = '구글 로그인에 실패했습니다.';
                              });
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.activeBlue)
                        : const Text(
                            '구글로 시작하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF222222),
                              letterSpacing: 0.32,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // SSO 버튼 (애플)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFE0E0E5), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(8),
                    color: CupertinoColors.white,
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            try {
                              final authVM = context.read<AuthViewModel>();
                              await authVM.signInWithApple();
                              if (authVM.errorMessage == null && mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) =>
                                          const TermsAgreementPage()),
                                  (route) => false,
                                );
                              } else if (authVM.errorMessage != null) {
                                setState(() {
                                  _errorMessage = authVM.errorMessage;
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _errorMessage = 'Apple 로그인에 실패했습니다.';
                              });
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.activeBlue)
                        : const Text(
                            'Apple로 시작하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF222222),
                              letterSpacing: 0.32,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                // 하단 로그인 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있으신가요? ',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF868687),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const LoginView()),
                        );
                      },
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: loginLinkColor,
                          letterSpacing: 0.56,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // '다음' 버튼 추가: 이용약관 페이지로 이동
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CupertinoButton(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const TermsAgreementPage()),
                      );
                    },
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
      ),
    );
  }
}
