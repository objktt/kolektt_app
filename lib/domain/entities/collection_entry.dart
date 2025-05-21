/// 컬렉션 추가 시 사용되는 데이터 모델 클래스
class CollectionEntry {
  final int recordId;
  final String title;
  final String artist;
  final int? year;
  final String genre;
  final String coverImage;
  final String catalogNumber;
  final String label;
  final String format;
  final String country;
  final String style;
  final String condition;
  final String conditionNotes;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String notes;
  final List<String> tags;
  final String source;

  CollectionEntry({
    required this.recordId,
    required this.title,
    required this.artist,
    this.year,
    required this.genre,
    required this.coverImage,
    required this.catalogNumber,
    required this.label,
    required this.format,
    required this.country,
    required this.style,
    required this.condition,
    required this.conditionNotes,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.notes,
    required this.tags,
    required this.source,
  });

  /// DB 삽입에 사용할 Map 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      // 'title': title, // user_collections에는 title 등 레코드 정보는 넣지 않음
      // 'year': year,
      // 'genre': genre,
      // 'cover_image': coverImage,
      // 'catalog_number': catalogNumber, // ❌ user_collections에는 catalog_number 포함 X
      // 'label': label,
      // 'format': format,
      // 'country': country,
      // 'style': style,
      'condition': condition,
      'condition_notes': conditionNotes,
      'purchase_price': purchasePrice,
      'purchase_date': purchaseDate.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'source': source,
    };
  }
}
