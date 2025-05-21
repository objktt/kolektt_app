import 'dart:core';

import 'package:flutter/material.dart';

import '../model/local/collection_record.dart';

/// Flutter의 HomeViewModel (ChangeNotifier 기반)
class HomeViewModel extends ChangeNotifier {
  // Private backing field
  List<CollectionRecord> _collectionRecords = [];

  // Public getter
  List<CollectionRecord> get collectionRecords => _collectionRecords;

  set collectionRecords(List<CollectionRecord> records) {
    _collectionRecords = records;
    notifyListeners();
  }

  HomeViewModel();
}
