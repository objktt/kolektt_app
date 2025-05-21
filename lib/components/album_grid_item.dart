import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/local/collection_record.dart';
import '../view/collection/collection_record_detail_view.dart';
import '../../model/record.dart';
import '../../domain/entities/discogs_record.dart';

class AlbumGridItem extends StatelessWidget {
  final CollectionRecord record;
  const AlbumGridItem({super.key, required this.record});

  // DiscogsRecord -> Record 변환 헬퍼
  Record discogsToRecord(DiscogsRecord d) {
    return Record(
      id: d.id.toString(),
      title: d.title,
      artist: d.artist,
      releaseYear: d.releaseYear,
      genre: d.genre,
      coverImageURL: d.coverImage,
      catalogNumber: d.catalogNumber,
      label: d.label,
      format: d.format,
      country: d.country,
      style: d.style,
      condition: d.condition,
      conditionNotes: d.conditionNotes,
      notes: d.notes,
      // createdAt, updatedAt, price, trending 등은 기본값 사용
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        // 상세 페이지로 이동 (CupertinoPageRoute) 및 결과 받기
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => CollectionRecordDetailView(
              record: discogsToRecord(record.record), // 변환 후 전달
            ),
          ),
        );
        if (result != null) {
          // 필요시 상태 반영
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 Stack (상태 칩 제거)
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: record.record.coverImage.isNotEmpty
                    ? Image.network(
                        record.record.coverImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(CupertinoIcons.music_note,
                            size: 40, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.record.artist,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  record.record.title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
