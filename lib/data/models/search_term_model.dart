import '../../domain/entities/search_term.dart';

class SearchTermModel extends SearchTerm {
  SearchTermModel({
    super.id,
    required super.term,
    required super.timestamp,
  });

  factory SearchTermModel.fromMap(Map<String, dynamic> map) {
    return SearchTermModel(
      id: map['id'] as int?,
      term: map['term'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'term': term,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
