import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/record_details_vm.dart';
import '../view_models/collection_vm.dart';
import 'collection/collection_edit_page.dart';

class RecordDetailsView extends StatefulWidget {
  const RecordDetailsView({super.key});

  // ... (existing code)
  @override
  _RecordDetailsViewState createState() => _RecordDetailsViewState();
}

class _RecordDetailsViewState extends State<RecordDetailsView> {
  @override
  Widget build(BuildContext context) {
    debugPrint('여기는 record_details_view.dart');
    final recordDetailsVM = context.watch<RecordDetailsViewModel>();
    final collectionVM = context.watch<CollectionViewModel>();
    final record = recordDetailsVM.collectionRecord.record;
    return Scaffold(
      appBar: AppBar(
        title: Text(record.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              debugPrint('편집 버튼 클릭됨(record_details_view.dart)');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CollectionEditPage(
                    collection: recordDetailsVM.collectionRecord,
                    onSave: (userCollection) async {
                      await recordDetailsVM.updateRecord(userCollection);
                      await recordDetailsVM.getRecordDetails();
                      await collectionVM.fetch();
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // ... existing code ...
    );
  }
}
