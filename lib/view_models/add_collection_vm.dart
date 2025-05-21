import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/discogs_search_response.dart';
import '../domain/entities/collection_entry.dart';
import '../domain/entities/record_condition.dart';
import '../domain/repositories/collection_repository.dart';
import '../domain/repositories/discogs_record_repository.dart';

class AddCollectionViewModel extends ChangeNotifier {
  // Repositories
  final CollectionRepository collectionRepository;
  final DiscogsRecordRepository discogsRecordRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  // TextEditingControllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _catalogNumberController =
      TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _styleController = TextEditingController();
  final TextEditingController _conditionNotesController =
      TextEditingController();

  // Private state fields
  late DiscogsSearchItem _record;
  DateTime _purchaseDate = DateTime.now();
  bool _isAdding = false;
  String? _errorMessage;
  RecordCondition _selectedCondition = RecordCondition.mint;
  List<String> _tagList = [];

  // Constructor
  AddCollectionViewModel({
    required this.collectionRepository,
    required this.discogsRecordRepository,
  });

  // Getters and setters for record
  DiscogsSearchItem get record => _record;
  set record(DiscogsSearchItem record) {
    _record = record;
  }

  // Getters for controllers
  TextEditingController get notesController => _notesController;
  TextEditingController get priceController => _priceController;
  TextEditingController get newTagController => _newTagController;
  TextEditingController get titleController => _titleController;
  TextEditingController get artistController => _artistController;
  TextEditingController get yearController => _yearController;
  TextEditingController get genreController => _genreController;
  TextEditingController get catalogNumberController => _catalogNumberController;
  TextEditingController get labelController => _labelController;
  TextEditingController get formatController => _formatController;
  TextEditingController get countryController => _countryController;
  TextEditingController get styleController => _styleController;
  TextEditingController get conditionNotesController =>
      _conditionNotesController;

  // Price parsing from the price controller text
  double get price {
    final text = _priceController.text.trim();
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  // Purchase date accessors
  DateTime get purchaseDate => _purchaseDate;
  set purchaseDate(DateTime date) {
    _purchaseDate = date;
    notifyListeners();
  }

  // isAdding flag
  bool get isAdding => _isAdding;
  set isAdding(bool value) {
    _isAdding = value;
    notifyListeners();
  }

  // errorMessage accessors
  String? get errorMessage => _errorMessage;
  set errorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Selected condition accessors
  RecordCondition get selectedCondition => _selectedCondition;
  set selectedCondition(RecordCondition condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  // Tag list accessors
  List<String> get tagList => _tagList;
  set tagList(List<String> tags) {
    _tagList = tags;
    notifyListeners();
  }

  /// 컬렉션에 레코드를 추가합니다.
  Future<void> addToCollection() async {
    isAdding = true;
    errorMessage = null;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // Discogs 레코드를 DB에 추가
      await _tryAddDiscogsRecord(_record);

      // CollectionEntry 인스턴스 생성 후, toJson()으로 변환하여 insert 처리
      final collectionEntry = CollectionEntry(
        recordId: _record.id,
        title: _record.title,
        artist: '', // DiscogsSearchItem에 artist 필드가 없으므로 빈 문자열로 처리 (추후 확장 가능)
        year: int.tryParse(_record.year ?? ''),
        genre: _record.genre.isNotEmpty ? _record.genre.join(', ') : '',
        coverImage: _record.coverImage ?? '',
        catalogNumber: _record.catno ?? '',
        label: _record.label.isNotEmpty ? _record.label.join(', ') : '',
        format: _record.format.isNotEmpty ? _record.format.join(', ') : '',
        country: _record.country ?? '',
        style: _record.style.isNotEmpty ? _record.style.join(', ') : '',
        condition: _selectedCondition.name,
        conditionNotes: '', // DiscogsSearchItem에 별도 필드 없으므로 빈 문자열
        purchasePrice: price,
        purchaseDate: _purchaseDate,
        notes: _notesController.text.trim(),
        tags: _tagList,
        source: 'discogs',
      );

      await collectionRepository.insert(collectionEntry);
    } catch (error) {
      errorMessage = '컬렉션 추가 실패: $error';
    } finally {
      isAdding = false;
    }
  }

  /// Discogs 레코드를 DB에 추가하는 내부 메서드.
  /// 오류 발생 시 상위로 재던짐(rethrow)합니다.
  Future<void> _tryAddDiscogsRecord(DiscogsSearchItem record) async {
    try {
      await discogsRecordRepository.addDiscogsRecord(record);
      log('Discogs record added successfully.');
    } catch (error) {
      log('Error inserting record: $error');
      rethrow;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _catalogNumberController.dispose();
    _labelController.dispose();
    _formatController.dispose();
    _countryController.dispose();
    _styleController.dispose();
    _conditionNotesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _newTagController.dispose();
    super.dispose();
  }
}
