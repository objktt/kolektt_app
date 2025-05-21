import 'package:flutter/cupertino.dart';
import 'id_setup_page.dart';

class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({super.key});

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  bool allAgreed = false;
  bool agreeService = false;
  bool agreePrivacy = false;
  bool agreeAge = false;
  bool agreeMarketing = false;

  void _toggleAll(bool? value) {
    setState(() {
      allAgreed = value ?? false;
      agreeService = allAgreed;
      agreePrivacy = allAgreed;
      agreeAge = allAgreed;
      agreeMarketing = allAgreed;
    });
  }

  void _toggleIndividual() {
    setState(() {
      allAgreed = agreeService && agreePrivacy && agreeAge && agreeMarketing;
    });
  }

  bool get canProceed => agreeService && agreePrivacy && agreeAge;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    const Color borderColor = Color(0xFFE0E0E5);
    const Color titleColor = Color(0xFF0E0E10);
    const Color descColor = Color(0xFF575758);
    const Color backgroundColor = CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '컬렉트 서비스\n이용 약관에 동의해주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Color(0xFF0E0E10),
                  height: 44 / 32,
                ),
              ),
              const SizedBox(height: 40),
              // 전체 동의
              _buildCheckbox(
                value: allAgreed,
                onChanged: _toggleAll,
                label: '필수 약관 모두 동의',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              const SizedBox(height: 24),
              // 개별 약관
              _buildCheckbox(
                value: agreeService,
                onChanged: (v) {
                  setState(() => agreeService = v ?? false);
                  _toggleIndividual();
                },
                label: '[필수] 서비스 이용약관',
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                value: agreePrivacy,
                onChanged: (v) {
                  setState(() => agreePrivacy = v ?? false);
                  _toggleIndividual();
                },
                label: '[필수] 개인정보 처리방침',
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                value: agreeAge,
                onChanged: (v) {
                  setState(() => agreeAge = v ?? false);
                  _toggleIndividual();
                },
                label: '[필수] 만 14세 이상',
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                value: agreeMarketing,
                onChanged: (v) {
                  setState(() => agreeMarketing = v ?? false);
                  _toggleIndividual();
                },
                label: '[선택] 마케팅 정보 수신 동의',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: canProceed ? primaryColor : borderColor,
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  onPressed: canProceed
                      ? () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => const IdSetupPage(),
                            ),
                          );
                        }
                      : null,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = 14,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF0036FF) : CupertinoColors.white,
              border: Border.all(
                color:
                    value ? const Color(0xFF0036FF) : const Color(0xFFE0E0E5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(CupertinoIcons.check_mark,
                    size: 16, color: CupertinoColors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: fontWeight,
              fontSize: fontSize,
              color: const Color(0xFF0E0E10),
            ),
          ),
        ],
      ),
    );
  }
}
