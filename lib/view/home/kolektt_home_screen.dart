import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:provider/provider.dart';

import '../../model/local/collection_record.dart';
import '../../view_models/analytics_vm.dart';
import '../../view_models/collection_vm.dart';
import '../auto_album_detection_view.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../../components/album_grid_item.dart';

class KolekttHomeScreen extends StatefulWidget {
  const KolekttHomeScreen({super.key});

  @override
  State<KolekttHomeScreen> createState() => _KolekttHomeScreenState();
}

class _KolekttHomeScreenState extends State<KolekttHomeScreen> {
  late AnalyticsViewModel analytics_model;
  final bool _isRefreshing = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollectionData();
    });
    _loadCollectionData();
  }

  Future<void> _loadCollectionData() async {
    final collectionModel = context.read<CollectionViewModel>();
    analytics_model = context.read<AnalyticsViewModel>();
    await collectionModel.fetch();

    analytics_model.analyzeRecords(collectionModel.collectionRecords);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Consumer2<AnalyticsViewModel, CollectionViewModel>(
          builder: (context, analytics, collection, child) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. 상단 헤더 (로고, +버튼)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kolektt',
                              style: TextStyle(
                                fontFamily: 'VampiroOne',
                                fontSize: 32,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'all about my records',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 44,
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) =>
                                    const AutoAlbumDetectionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0052FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.add,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 2. 사용자 요약 카드 (아티스트/장르/레코드)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 전체폭 아티스트 카드
                        _ArtistCard(analytics, collection),
                        const SizedBox(height: 12),
                        // 하단 2개 카드 (좌우 1:1)
                        Row(
                          children: [
                            Expanded(child: _GenreCard(analytics)),
                            const SizedBox(width: 12),
                            Expanded(child: _RecordCountCard(analytics)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 3. 컬렉션 섹션 헤더 + 검색바
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나의 컬렉션',
                          style: const FigmaTextStyles()
                              .headingheading2
                              .copyWith(color: FigmaColors.grey100),
                        ),
                        const SizedBox(height: 16),
                        _SearchBar(),
                      ],
                    ),
                  ),
                ),
                // 4. 앨범 그리드
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
                  sliver: Builder(
                    builder: (context) {
                      final records =
                          context.read<CollectionViewModel>().collectionRecords;
                      final filteredRecords = _searchQuery.isEmpty
                          ? records
                          : records.where((record) {
                              final query = _searchQuery.toLowerCase();
                              return record.record.title
                                      .toLowerCase()
                                      .contains(query) ||
                                  record.record.artist
                                      .toLowerCase()
                                      .contains(query);
                            }).toList();
                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final record = filteredRecords[index];
                            return AlbumGridItem(record: record);
                          },
                          childCount: filteredRecords.length,
                        ),
                      );
                    },
                  ),
                ),
                // 5. 하단 여백
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _StatCard(
      {required String title, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTypography.caption
                    .copyWith(color: CupertinoColors.white)),
            const SizedBox(height: 8),
            Text(value,
                style: AppTypography.heading2
                    .copyWith(color: CupertinoColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _AlbumCard({required CollectionRecord record}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: record.record.coverImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(record.record.coverImage),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.divider,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(record.record.title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(record.record.artist, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(
            '${record.record.releaseYear} • ${record.record.genre}',
            style: AppTypography.caption.copyWith(color: AppColors.divider),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.record.condition,
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ArtistCard(
      AnalyticsViewModel analytics, CollectionViewModel collection) {
    final artist = analytics.analytics?.mostCollectedArtist ?? '-';
    // 해당 아티스트의 모든 레코드 필터링
    final artistRecords = collection.collectionRecords
        .where((r) => r.record.artist.split(', ').contains(artist))
        .toList();
    // 가장 최근 등록(최신 releaseYear, 없으면 리스트 마지막)
    artistRecords
        .sort((a, b) => b.record.releaseYear.compareTo(a.record.releaseYear));
    final latestRecord = artistRecords.isNotEmpty ? artistRecords.first : null;
    final coverImage = latestRecord?.record.coverImage ?? '';
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '나의 최고 아티스트',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist,
                    style: AppTypography.heading2.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A1F),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: coverImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32),
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _GenreCard(AnalyticsViewModel analytics) {
    final genre = analytics.analytics?.mostCollectedGenre ?? '-';
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF99AAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '나의 최고 장르',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              genre,
              style: AppTypography.heading2.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _RecordCountCard(AnalyticsViewModel analytics) {
    final count = analytics.analytics?.totalRecords.toString() ?? '0';
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0052FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '나의 레코드',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count장',
              style: AppTypography.heading2.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(CupertinoIcons.search,
              color: CupertinoColors.systemGrey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              placeholder: '검색어를 입력하세요.',
              placeholderStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: CupertinoColors.systemGrey2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: null,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 36,
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) => CupertinoActionSheet(
                  title: const Text('필터'),
                  message: const Text('필터 옵션을 선택하세요.'),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () => _safePop(context),
                      child: const Text('장르별 필터'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => _safePop(context),
                      child: const Text('아티스트별 필터'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => _safePop(context),
                    child: const Text('취소'),
                  ),
                ),
              );
            },
            child: const Icon(
              CupertinoIcons.line_horizontal_3_decrease_circle,
              color: CupertinoColors.systemGrey,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
