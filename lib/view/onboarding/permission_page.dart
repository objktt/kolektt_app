import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    await Permission.notification.request();
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.locationWhenInUse.request();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingComplete', true);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    const Color dividerColor = CupertinoColors.systemGrey4;
    const Color iconColor = CupertinoColors.black;
    const TextStyle titleStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: Color(0xFF0E0E10),
      height: 1.33,
    );
    const TextStyle sectionTitleStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Color(0xFF0E0E10),
    );
    const TextStyle descStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xFF575758),
      height: 1.4,
    );
    const TextStyle infoStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Color(0xFF575758),
      height: 1.5,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('앱 사용을 위해\n접근 권한을 허용해주세요', style: titleStyle),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 1,
                color: dividerColor,
              ),
              const SizedBox(height: 20),
              const Text('선택 권한', style: sectionTitleStyle),
              const SizedBox(height: 16),
              const _PermissionItem(
                icon: CupertinoIcons.bell,
                title: '알림',
                desc: '알림 메시지 발송',
                iconColor: iconColor,
              ),
              const SizedBox(height: 16),
              const _PermissionItem(
                icon: CupertinoIcons.camera,
                title: '카메라',
                desc: '레코드 인식을 위해 필요합니다.',
                iconColor: iconColor,
              ),
              const SizedBox(height: 16),
              const _PermissionItem(
                icon: CupertinoIcons.photo,
                title: '사진',
                desc: '이미지 업로드를 위해 필요합니다.',
                iconColor: iconColor,
              ),
              const SizedBox(height: 16),
              const _PermissionItem(
                icon: CupertinoIcons.location,
                title: '위치',
                desc: '주변 레코드샵 정보 제공을 위해 필요합니다.',
                iconColor: iconColor,
              ),
              const SizedBox(height: 24),
              const Text(
                '선택 권한의 경우 허용하지 않아도 서비스를 사용할 수 있으나 일부 서비스 이용이 제한될 수 있습니다.',
                style: infoStyle,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const CupertinoActivityIndicator(radius: 16)
                    : CupertinoButton(
                        color: const Color(0xFF0036FF),
                        borderRadius: BorderRadius.circular(8),
                        padding: EdgeInsets.zero,
                        onPressed: _requestPermissions,
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: CupertinoColors.white,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color iconColor;
  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF0E0E10),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF575758),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
