import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:kolektt/view_models/collection_vm.dart';
import 'package:provider/provider.dart';

import '../../data/models/discogs_record.dart';
import '../../model/local/collection_record.dart';
import '../../model/supabase/user_collection.dart';
import '../../view_models/record_details_vm.dart';
import '../artist_detail_view.dart';
import 'collection_edit_page.dart';
import 'package:kolektt/view/edit_record_view.dart';
import 'package:kolektt/view/edit_record_discogs_view.dart';
import 'package:kolektt/domain/entities/collection_entry.dart';

class RecordDetailsView extends StatefulWidget {
  final CollectionRecord collectionRecord;

  const RecordDetailsView({
    super.key,
    required this.collectionRecord,
  });

  @override
  State<RecordDetailsView> createState() => _RecordDetailsViewState();
}

class _RecordDetailsViewState extends State<RecordDetailsView> {
  final FigmaTextStyles _textStyles = FigmaTextStyles();
  int currentPage = 0;
  final int pageCount = 1; // 이미지 개수에 맞게 동적으로 변경 필요

  @override
  void initState() {
    super.initState();
    final recordDetailsVM = context.read<RecordDetailsViewModel>();
    recordDetailsVM.collectionRecord = widget.collectionRecord;
    debugPrint(
        "Model artist: ${recordDetailsVM.collectionRecord.record.artist}");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: lib/view/collection/record_detail_view.dart');
    final recordDetailsVM = context.watch<RecordDetailsViewModel>();
    final collectionVM = context.watch<CollectionViewModel>();
    final record = recordDetailsVM.collectionRecord.record;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: Navigator.canPop(context)
            ? const CupertinoNavigationBarBackButton(previousPageTitle: '')
            : null,
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.pencil),
          onPressed: () {
            debugPrint(
                'onPressed(연필): lib/view/collection/record_detail_view.dart');
            final userCollection =
                recordDetailsVM.collectionRecord.user_collection;
            final entry = CollectionEntry(
              recordId: record.id,
              title: record.title,
              artist: record.artist,
              year: record.releaseYear,
              genre: record.genre,
              coverImage: record.coverImage,
              catalogNumber: record.catalogNumber ?? '',
              label: record.label ?? '',
              format: record.format ?? '',
              country: record.country ?? '',
              style: record.style ?? '',
              condition: userCollection.condition ?? '',
              conditionNotes: userCollection.condition_note ?? '',
              purchasePrice: userCollection.purchase_price,
              purchaseDate: userCollection.purchase_date ?? DateTime.now(),
              notes: userCollection.notes ?? '',
              tags: userCollection.tags ?? [],
              source: userCollection.source ?? 'manual',
            );
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) {
                  if (entry.source == 'manual') {
                    return EditRecordView(
                      entry: entry,
                      onSave: (updated) async {
                        await collectionVM.updateRecord(updated);
                        await collectionVM.fetch();
                        Navigator.pop(context);
                      },
                      onDelete: (recordId) async {
                        await collectionVM.deleteRecord(recordId);
                        await collectionVM.fetch();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    );
                  } else {
                    return EditRecordDiscogsView(
                      entry: entry,
                      onSave: (updated) async {
                        await collectionVM.updateRecord(updated);
                        await collectionVM.fetch();
                        Navigator.pop(context);
                      },
                      onDelete: (recordId) async {
                        await collectionVM.deleteRecord(recordId);
                        await collectionVM.fetch();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildCoverImage(record),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),
            SliverToBoxAdapter(
              child: Center(child: _buildPageIndicator()),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: _buildTitleSection(record, recordDetailsVM),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
            SliverToBoxAdapter(
              child: _buildRecordDetailsSection(),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
            SliverToBoxAdapter(
              child: _buildConditionSection(
                recordDetailsVM.collectionRecord.user_collection,
                record,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditPage(
    RecordDetailsViewModel recordDetailsVM,
    CollectionViewModel collectionVM,
  ) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => CollectionEditPage(
          collection: widget.collectionRecord,
          onSave: (userCollection) async {
            await recordDetailsVM.updateRecord(userCollection);
            await recordDetailsVM.getRecordDetails();
            await collectionVM.fetch();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildCoverImage(dynamic record) {
    final List<String> images = [
      if (record.coverImage != null && record.coverImage.isNotEmpty)
        record.coverImage,
      if (record.backCoverImage != null && record.backCoverImage.isNotEmpty)
        record.backCoverImage,
      // 미리듣기(Preview) 관련 필드/위젯 완전히 제거
    ];
    final double imageSize = MediaQuery.of(context).size.width * 0.8;

    return Column(
      children: [
        SizedBox(
          height: imageSize,
          child: PageView.builder(
            itemCount: images.isNotEmpty ? images.length : 1,
            onPageChanged: (idx) => setState(() => currentPage = idx),
            itemBuilder: (context, idx) {
              final imageUrl = images.isNotEmpty
                  ? images[idx]
                  : 'https://via.placeholder.com/600x600';
              return Semantics(
                label: '앨범 커버 이미지',
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: CupertinoColors.systemGrey5,
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: imageSize,
                        height: imageSize,
                        color: CupertinoColors.systemGrey5,
                        child: const Icon(
                          CupertinoIcons.photo,
                          size: 48,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (idx) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == idx
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection(
      dynamic record, RecordDetailsViewModel recordDetailsVM) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.title,
            style: _textStyles.headingheading2
                .copyWith(color: CupertinoColors.black),
          ),
          const SizedBox(height: 4),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showArtistActionSheet(recordDetailsVM),
            child: Text(
              record.artist,
              style:
                  _textStyles.bodylg.copyWith(color: const Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${record.format.isNotEmpty ? record.format : 'N/A'} / ${record.releaseYear} / ${widget.collectionRecord.user_collection.condition ?? record.condition}',
            style: _textStyles.bodylg.copyWith(color: const Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  void _showArtistActionSheet(RecordDetailsViewModel recordDetailsVM) {
    final List<Artist> artists = recordDetailsVM.entityRecord!.artists;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext popupContext) {
        return CupertinoActionSheet(
          title: const Text('Artist'),
          actions: [
            for (final artist in artists)
              CupertinoActionSheetAction(
                onPressed: () {
                  // popupContext를 사용하여 모달 팝업을 닫습니다.
                  Navigator.pop(popupContext);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ArtistDetailView(artist: artist),
                    ),
                  );
                  debugPrint('Artist: ${artist.toJson()}');
                },
                child: Text(artist.name),
              ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(popupContext),
              child: const Text(
                '닫기',
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordDetailsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record\nDetails',
            style: _textStyles.headingheading4
                .copyWith(color: FigmaColors.grey100),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  _buildTableCell('Catalog Number', '88883716861'),
                  _buildTableCell('Label', 'Columbia'),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('Country', 'USA'),
                  _buildTableCell('Released', '2025'),
                ],
              ),
              TableRow(
                children: [
                  _buildTableCell('Genre', 'Electronic, Pop'),
                  _buildTableCell('Speed', '33 RPM'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                _textStyles.headingheading6.copyWith(color: FigmaColors.grey90),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: _textStyles.bodysm.copyWith(color: CupertinoColors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection(UserCollection userCollection, dynamic record) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condition',
            style: _textStyles.headingheading4
                .copyWith(color: FigmaColors.grey100),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  _buildConditionLabel('Media Grade'),
                  _buildConditionValue(
                      userCollection.condition ?? record.condition),
                ],
              ),
              TableRow(
                children: [
                  _buildConditionLabel('Sleeve Grade'),
                  _buildConditionValue(userCollection.condition_note ?? "N/A"),
                ],
              ),
            ],
          ),
          if ((userCollection.condition_note ?? '').isNotEmpty)
            Text(
              userCollection.condition_note ?? '',
              style:
                  _textStyles.bodysm.copyWith(color: const Color(0xFF4B5563)),
            ),
        ],
      ),
    );
  }

  Widget _buildConditionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style:
            _textStyles.headingheading6.copyWith(color: CupertinoColors.black),
      ),
    );
  }

  Widget _buildConditionValue(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        value,
        style: _textStyles.bodysm.copyWith(color: FigmaColors.primary60),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount, // 이미지 개수에 맞게 동적으로 변경 필요
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey3,
          ),
        ),
      ),
    );
  }
}
