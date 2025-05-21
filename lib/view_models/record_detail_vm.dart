import 'package:flutter/foundation.dart';
import 'package:kolektt/domain/repositories/discogs_repository.dart';
import 'package:kolektt/model/local/sales_listing_with_profile.dart';
import 'package:kolektt/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/discogs_record.dart';
import '../model/supabase/sales_listings.dart';
import '../repository/sale_repository.dart';
import '../model/supabase/user_collection.dart';

class RecordDetailViewModel extends ChangeNotifier {
  final DiscogsRepository discogsRepository;
  final SaleRepository _saleRepository = SaleRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final String recordResourceUrl;

  DiscogsRecord? _detailedRecord;
  DiscogsRecord? get detailedRecord => _detailedRecord;

  UserCollection? _userCollection;
  UserCollection? get user_collection => _userCollection;

  bool isLoading = true;
  String? errorMessage;

  bool _fetchingSellers = true;

  bool get fetchingSellers => _fetchingSellers;

  final SalesListingWithProfile _salesListingWithProfile =
      SalesListingWithProfile(salesListing: [], profiles: []);

  SalesListingWithProfile? get salesListingWithProfile =>
      _salesListingWithProfile;

  RecordDetailViewModel(
      {required this.recordResourceUrl, required this.discogsRepository}) {
    fetchRecordDetails(int.parse(recordResourceUrl.split("/").last)).then((_) {
      updateRecordToDb();
      notifyListeners();
    }).then((_) {
      getSellers();
      notifyListeners();
    });
  }

  Future<void> fetchRecordDetails(int id) async {
    try {
      _detailedRecord = await discogsRepository.getReleaseById(id);
      // user_collection도 함께 fetch
      final supabase = Supabase.instance.client;
      final userId = _profileRepository.getCurrentUserId();
      final response = await supabase
          .from('user_collections')
          .select()
          .eq('record_id', id)
          .eq('user_id', userId)
          .maybeSingle();
      if (response != null) {
        _userCollection = UserCollection.fromJson(response);
      } else {
        _userCollection = null;
      }
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecordToDb() async {
    // TODO: Supabase로 업데이트하는 로직 추가
    // final supabase = Supabase.instance.client;
    //
    // if (_detailedRecord == null) return;
    // // 전체 JSON 생성
    // final detailRecordJson = _detailedRecord!.toJson();
    //
    // // cover_image와 format 키 제거
    // detailRecordJson.remove('cover_image');
    // detailRecordJson.remove('format');
    //
    // debugPrint('Updating record (without cover_image and format): $detailRecordJson');
    //
    // final response = await supabase
    //     .from('records')
    //     .update(detailRecordJson)
    //     .eq('record_id', _baseRecord.id);
    //
    // debugPrint('Record updated: $response');
  }

  Future<void> getSellers() async {
    if (_detailedRecord == null) return;
    try {
      _fetchingSellers = true;
      notifyListeners();

      List<SalesListing> salesListing =
          await _saleRepository.getSaleByRecordId(_detailedRecord!.id);
      debugPrint("SalesListing: $salesListing");
      debugPrint("detailedRecord!.id ${salesListing[0]}");

      if (salesListing.isEmpty) {
        _fetchingSellers = false;
        notifyListeners();
        return;
      }

      // ProfileRepository를 사용하여 판매자 정보 가져오기
      final sellersList = salesListing.map((e) => e.userId).toList();
      debugPrint("Sellers list: $sellersList");
      final sellers =
          await _profileRepository.getProfilesByUserIds(sellersList);

      debugPrint("Sellers: $sellers");

      // SalesListing에 판매자 정보 추가한 새 리스트 생성
      _salesListingWithProfile.salesListing = salesListing;
      _salesListingWithProfile.profiles = sellers;
      notifyListeners();

      debugPrint('Sellers item: ${_salesListingWithProfile.profiles.length}');
    } catch (e) {
      debugPrint('Error getting sellers: $e');
    } finally {
      _fetchingSellers = false;
      notifyListeners();
    }
  }
}
