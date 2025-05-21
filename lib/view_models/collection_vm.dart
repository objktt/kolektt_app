import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kolektt/model/local/collection_record.dart';
import 'package:kolektt/model/recognition.dart';
import 'package:kolektt/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/discogs_search_response.dart';
import '../data/models/user_collection_classification.dart';
import '../domain/entities/album_recognition_result.dart';
import '../domain/entities/collection_entry.dart';
import '../domain/repositories/collection_repository.dart';
import '../domain/repositories/discogs_repository.dart';
import '../domain/usecases/recognize_album.dart';
import '../domain/usecases/search_and_upsert_discogs_records.dart';
import '../model/collection_analytics.dart';
import '../model/local/collection_classification.dart'; // classifyCollections 함수와 CollectionClassification 클래스 포함
import '../data/datasources/record_data_source.dart';
import '../data/datasources/collection_remote_data_source.dart';

class CollectionViewModel extends ChangeNotifier {
  final SearchAndUpsertDiscogsRecords searchAndUpsertUseCase;

  final RecognizeAlbumUseCase recognizeAlbumUseCase;

  CollectionRepository collectionRepository;
  final ProfileRepository _profileRepository = ProfileRepository();

  File? selectedImage;
  RecognitionResult? recognitionResult;
  CollectionAnalytics? analytics;

  AlbumRecognitionResult? _albumRecognitionResult;

  AlbumRecognitionResult? get albumRecognitionResult => _albumRecognitionResult;

  UserCollectionClassification _userCollectionClassification =
      UserCollectionClassification.initial();

  UserCollectionClassification get userCollectionClassification =>
      _userCollectionClassification;

  set userCollectionClassification(
      UserCollectionClassification classification) {
    _userCollectionClassification = classification;
    notifyListeners();
  }

  final SupabaseClient supabase = Supabase.instance.client;
  final bool _isAdding = false;

  bool get isAdding => _isAdding;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  set errorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Vision API로부터 가져온 라벨
  String? _lastRecognizedLabel;

  String? get lastRecognizedLabel => _lastRecognizedLabel;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<DiscogsSearchItem> _searchResults = [];

  List<DiscogsSearchItem> get searchResults => _searchResults;

  final List<String> _partialMatchingImages = [];

  List<String> get partialMatchingImages => _partialMatchingImages;

  // Private backing field
  List<CollectionRecord> _collectionRecords = [];

  // Public getter
  List<CollectionRecord> get collectionRecords => _collectionRecords;

  // Public setter (컬렉션 업데이트 시 notifyListeners)
  set collectionRecords(List<CollectionRecord> records) {
    _collectionRecords = records;
    notifyListeners();
  }

  String get userId => _profileRepository.getCurrentUserId();

  // 분류 결과 (장르/레이블/아티스트)
  CollectionClassification? classification;

  CollectionViewModel({
    required this.recognizeAlbumUseCase,
    required this.searchAndUpsertUseCase,
    required DiscogsRepository discogs_repository,
    required this.collectionRepository,
  });

  Future<void> removeRecord(CollectionRecord record) async {
    try {
      collectionRepository.delete(record.user_collection.id);
      _collectionRecords.removeWhere(
          (r) => r.user_collection.id == record.user_collection.id);
      notifyListeners();
      debugPrint('Record removed successfully.');
    } catch (e) {
      debugPrint('Error in removeRecord: $e');
    }
  }

  /// 앨범 인식을 실행하고, 인식된 키워드로 Discogs 검색을 수행합니다.
  Future<void> recognizeAlbum(File image) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. 도메인 Use Case를 통해 앨범 인식 실행
      final result = await recognizeAlbumUseCase.execute(image);
      _albumRecognitionResult = result;
      // 2. 인식된 키워드를 기반으로 Discogs 검색 실행
      if (result.bestGuessLabel == null) {
        _errorMessage = '앨범 인식 실패: $_errorMessage';
        return;
      }
      await searchOnDiscogs(result.bestGuessLabel!);
    } catch (e) {
      _errorMessage = '앨범 인식 중 오류 발생: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Discogs API로 검색
  Future<void> searchOnDiscogs(String query) async {
    if (query.isEmpty) return;
    try {
      final results = await searchAndUpsertUseCase.call(query, type: 'release');
      _searchResults = results;
    } catch (e) {
      _errorMessage = 'Discogs 검색 오류: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetch() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _fetchUserCollectionsWithRecords();
      await _fetchUserCollectionsUniqueProperties();
    } catch (e) {
      _errorMessage = '컬렉션을 불러오는 중 오류가 발생했습니다: $e';
      debugPrint('Error fetching user collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    _collectionRecords = [];
    _userCollectionClassification = _userCollectionClassification.copyWith(
      mediaCondition: "All",
      sleeveCondition: "All",
      genre: 'All',
      startYear: 1900,
      endYear: 2025,
      sortOption: '최신순',
    );
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 컬렉션을 불러온 후, CollectionClassification 함수를 호출하여 분류 결과를 저장합니다.
  Future<void> _fetchUserCollectionsWithRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      collectionRecords = await collectionRepository.fetch(userId);
      classification = classifyCollections(collectionRecords);
    } catch (e) {
      _errorMessage = '컬렉션을 불러오는 중 오류가 발생했습니다: $e';
      debugPrint('Error fetching user collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserCollectionsUniqueProperties() async {
    try {
      _isLoading = true;
      notifyListeners();

      _userCollectionClassification =
          await collectionRepository.fetchUniqueProperties(userId);
      debugPrint(
          'UserCollectionClassification: ${_userCollectionClassification.genres}, mediaCondition: ${_userCollectionClassification.mediaCondition}');
    } catch (e) {
      _errorMessage = '컬렉션을 불러오는 중 오류가 발생했습니다: $e';
      debugPrint('Error fetching user collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterCollection() async {
    try {
      _isLoading = true;
      notifyListeners();

      _collectionRecords = await collectionRepository.fetchFilter(
          userId, _userCollectionClassification);

      for (var record in _collectionRecords) {
        debugPrint('Filtered record: ${record.record.title}');
      }
    } catch (e) {
      _errorMessage = '컬렉션 필터링 중 오류가 발생했습니다: $e';
      debugPrint('Error filtering user collection: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 수동입력/직접 추가용 컬렉션 저장 메서드
  Future<void> addRecord({
    required String title,
    required String artist,
    int? year,
    required String genre,
    required String notes,
    int? price,
    required String condition,
    File? image,
    String? coverImage,
    String? catalogNumber,
    String? label,
    String? format,
    String? country,
    String? style,
    String? conditionNotes,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      // 1. records 테이블에 upsert (source: 'manual')
      final recordId = DateTime.now().millisecondsSinceEpoch;
      final recordJson = {
        'record_id': recordId,
        'title': title,
        'artist': artist,
        'release_year': year,
        'genre': genre,
        'cover_image': coverImage ?? '',
        'catalog_number': catalogNumber ?? '',
        'label': label ?? '',
        'format': format ?? '',
        'country': country ?? '',
        'style': style ?? '',
        'source': 'manual',
      };
      final recordDataSource = RecordDataSource(supabase: supabase);
      await recordDataSource.insertRecord(recordJson);
      // 2. user_collections 테이블에 insert (source: 'manual')
      final userId = _profileRepository.getCurrentUserId();
      final userCollectionJson = {
        'user_id': userId,
        'record_id': recordId,
        'condition': condition,
        'condition_notes': conditionNotes ?? '',
        'purchase_price': (price ?? 0).toDouble(),
        'purchase_date': DateTime.now().toIso8601String(),
        'notes': notes,
        'tags': tags ?? [],
        'source': 'manual',
      };
      final collectionRemoteDataSource =
          CollectionRemoteDataSource(supabase: supabase);
      await collectionRemoteDataSource.insertUserCollection(userCollectionJson);
      await fetch();
    } catch (e) {
      _errorMessage = '컬렉션 추가 실패: $e';
      debugPrint('Error in addRecord: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 컬렉션 레코드 수정
  Future<void> updateRecord(CollectionEntry entry) async {
    try {
      _isLoading = true;
      notifyListeners();
      // records 테이블 업데이트
      final recordDataSource = RecordDataSource(supabase: supabase);
      final recordJson = {
        'record_id': entry.recordId,
        'title': entry.title,
        'artist': entry.artist,
        'release_year': entry.year,
        'genre': entry.genre,
        'cover_image': entry.coverImage,
        'catalog_number': entry.catalogNumber,
        'label': entry.label,
        'format': entry.format,
        'country': entry.country,
        'style': entry.style,
        'source': entry.source,
      };
      await recordDataSource.insertRecord(recordJson); // upsert로 동작
      // user_collections 테이블 업데이트
      final userId = _profileRepository.getCurrentUserId();
      final userCollectionJson = {
        'user_id': userId,
        'record_id': entry.recordId,
        'condition': entry.condition,
        'condition_notes': entry.conditionNotes,
        'purchase_price': entry.purchasePrice,
        'purchase_date': entry.purchaseDate.toIso8601String(),
        'notes': entry.notes,
        'tags': entry.tags,
        'source': entry.source,
      };
      final collectionRemoteDataSource =
          CollectionRemoteDataSource(supabase: supabase);
      await collectionRemoteDataSource
          .insertUserCollection(userCollectionJson); // upsert
      await fetch();
    } catch (e) {
      _errorMessage = '컬렉션 수정 실패: $e';
      debugPrint('Error in updateRecord: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 컬렉션 레코드 삭제
  Future<void> deleteRecord(int recordId) async {
    try {
      _isLoading = true;
      notifyListeners();
      // user_collections에서 삭제
      final collectionRemoteDataSource =
          CollectionRemoteDataSource(supabase: supabase);
      await supabase
          .from('user_collections')
          .delete()
          .eq('record_id', recordId);
      // records에서 삭제
      final recordDataSource = RecordDataSource(supabase: supabase);
      await supabase.from('records').delete().eq('record_id', recordId);
      await fetch();
    } catch (e) {
      _errorMessage = '컬렉션 삭제 실패: $e';
      debugPrint('Error in deleteRecord: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
