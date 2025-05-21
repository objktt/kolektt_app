import 'package:flutter/cupertino.dart';

import '../model/popular_record.dart';

class PopularRecordRow extends StatelessWidget {
  final PopularRecord record;
  final int rank;
  const PopularRecordRow({super.key, required this.record, required this.rank});
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (_) => RecordDetailView(
        //       record: Record(
        //         id: record.id,
        //         title: record.title,
        //         artist: record.artist,
        //         releaseYear: 2024,
        //         genre: "Jazz",
        //         coverImageURL: record.imageUrl,
        //         notes: "",
        //         price: record.price,
        //         trending: record.trending,
        //       ),
        //     ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                record.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(record.artist,
                      style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text("₩${record.price}", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Icon(
              record.trending ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down,
              color: record.trending ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
            ),
          ],
        ),
      ),
    );
  }
}
