import 'package:flutter/cupertino.dart';
import '../content_view.dart';

class GenreSelectPage extends StatefulWidget {
  const GenreSelectPage({super.key});

  @override
  State<GenreSelectPage> createState() => _GenreSelectPageState();
}

class _GenreSelectPageState extends State<GenreSelectPage> {
  final List<String> _genres = [
    '팝',
    '힙합',
    '록',
    '재즈',
    '클래식',
    'R&B',
    'EDM',
    '인디',
    '트로트',
    '포크',
    '발라드',
    '댄스',
    '메탈',
    '블루스',
    '소울',
    '기타'
  ];
  final Set<String> _selectedGenres = {};

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _onNext() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => const ContentView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    const Color borderColor = Color(0xFFE0E0E5);
    const Color selectedColor = Color(0xFF0036FF);
    const Color unselectedColor = CupertinoColors.systemGrey6;
    final Color textColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final Color backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '장르 선택',
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
                '좋아하는 음악 장르를\n선택해주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  height: 36 / 28,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: _genres.map((genre) {
                  final bool selected = _selectedGenres.contains(genre);
                  return GestureDetector(
                    onTap: () => _toggleGenre(genre),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selected ? selectedColor : unselectedColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected ? selectedColor : borderColor,
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: selectedColor.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: selected ? CupertinoColors.white : textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color:
                      _selectedGenres.isNotEmpty ? primaryColor : borderColor,
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  onPressed: _selectedGenres.isNotEmpty ? _onNext : null,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: CupertinoButton(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(8),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(builder: (_) => const ContentView()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    '홈으로',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: CupertinoColors.black,
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
