import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../components/album_image_view.dart';
import '../../components/metadata_row.dart';
import '../../model/record.dart';
import 'package:kolektt/view/edit_record_view.dart';
import 'package:kolektt/view/edit_record_discogs_view.dart';
import 'package:kolektt/domain/entities/collection_entry.dart';
import 'package:kolektt/view_models/collection_vm.dart';
import 'package:provider/provider.dart';

class CollectionRecordDetailView extends StatefulWidget {
  final Record record;

  const CollectionRecordDetailView({super.key, required this.record});

  @override
  _CollectionRecordDetailViewState createState() =>
      _CollectionRecordDetailViewState();
}

class _CollectionRecordDetailViewState
    extends State<CollectionRecordDetailView> {
  bool showingEditSheet = false;
  late String selectedCondition;
  int currentPage = 0;

  final Map<String, String> conditions = {
    "M": "Mint (완벽한 상태)",
    "NM": "Near Mint (거의 새것)",
    "VG+": "Very Good Plus (매우 좋음)",
    "VG": "Very Good (좋음)",
    "G+": "Good Plus (양호)",
    "G": "Good (보통)",
    "F": "Fair (나쁨)"
  };

  @override
  void initState() {
    super.initState();
    selectedCondition = widget.record.condition ?? "NM";
  }

  List<String> get albumImageUrls {
    final urls = <String>[];
    if (widget.record.coverImageURL != null &&
        widget.record.coverImageURL!.isNotEmpty) {
      urls.add(widget.record.coverImageURL!);
    }
    // 뒷면 이미지 등 추가 필드가 있다면 여기에 push
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const double horizontalMargin = 16;
    final double imageSize = mediaQuery.size.width * 0.8;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.record.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.pencil),
          onPressed: () {
            final record = widget.record;
            print('DEBUG: record.source = \'${record.source}\'');
            final isDiscogs = record.source == 'discogs';
            final entry = CollectionEntry(
              recordId: int.tryParse(record.id) ?? 0,
              title: record.title,
              artist: record.artist,
              year: record.releaseYear,
              genre: record.genre ?? '',
              coverImage: record.coverImageURL ?? '',
              catalogNumber: record.catalogNumber ?? '',
              label: record.label ?? '',
              format: record.format ?? '',
              country: record.country ?? '',
              style: record.style ?? '',
              condition: record.condition ?? '',
              conditionNotes: record.conditionNotes ?? '',
              purchasePrice: record.price.toDouble(),
              purchaseDate: record.createdAt,
              notes: record.notes ?? '',
              tags: [],
              source: record.source,
            );
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => isDiscogs
                    ? EditRecordDiscogsView(
                        entry: entry,
                        onSave: (updated) async {
                          Navigator.pop(context);
                        },
                        onDelete: (recordId) async {
                          final collectionVM =
                              context.read<CollectionViewModel>();
                          await collectionVM.deleteRecord(recordId);
                          await collectionVM.fetch();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      )
                    : EditRecordView(
                        entry: entry,
                        onSave: (updated) async {
                          Navigator.pop(context);
                        },
                        onDelete: (recordId) async {
                          final collectionVM =
                              context.read<CollectionViewModel>();
                          await collectionVM.deleteRecord(recordId);
                          await collectionVM.fetch();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 40 + mediaQuery.padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 최신 iOS 스타일 앨범 이미지 영역
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Center(
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: PageView.builder(
                        itemCount: albumImageUrls.isNotEmpty
                            ? albumImageUrls.length
                            : 1,
                        onPageChanged: (idx) =>
                            setState(() => currentPage = idx),
                        itemBuilder: (context, idx) {
                          final imageUrl = albumImageUrls.isNotEmpty
                              ? albumImageUrls[idx]
                              : 'https://via.placeholder.com/600x600';
                          return Semantics(
                            label: '앨범 커버 이미지',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: CupertinoColors.systemGrey5,
                                        child: const Center(
                                          child: CupertinoActivityIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (albumImageUrls.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      albumImageUrls.length,
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
                const SizedBox(height: 24),
                // 앨범명/아티스트 (좌우 마진 적용)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.record.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.record.artist,
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 레코드 기본 정보 (좌우 마진 적용)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Column(
                    children: [
                      MetadataRow(
                        title: '카탈로그 번호',
                        value: widget.record.catalogNumber ?? '미등록',
                      ),
                      MetadataRow(
                        title: '레이블',
                        value: widget.record.label ?? '미등록',
                      ),
                      MetadataRow(
                        title: '포맷',
                        value: widget.record.format ?? '미등록',
                      ),
                      MetadataRow(
                        title: '국가',
                        value: widget.record.country ?? '미등록',
                      ),
                      MetadataRow(
                        title: '발매년도',
                        value: widget.record.releaseYear?.toString() ?? '미등록',
                      ),
                      MetadataRow(
                        title: '장르',
                        value: widget.record.genre ?? '미등록',
                      ),
                      MetadataRow(
                        title: '스타일',
                        value: widget.record.style ?? '미등록',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Divider(),
                ),
                // 가격/상태/메모 정보 (좌우 마진 적용)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: Column(
                    children: [
                      MetadataRow(
                        title: '가격',
                        value: widget.record.price != null
                            ? '${widget.record.price}원'
                            : '미등록',
                      ),
                      MetadataRow(
                        title: '상태',
                        value: widget.record.condition != null
                            ? (conditions[widget.record.condition] ??
                                widget.record.condition!)
                            : '미등록',
                      ),
                      MetadataRow(
                        title: '메모',
                        value: widget.record.notes?.isNotEmpty == true
                            ? widget.record.notes!
                            : '미등록',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MetadataRow extends StatelessWidget {
  final String title;
  final String value;
  const MetadataRow({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.secondaryLabel)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
