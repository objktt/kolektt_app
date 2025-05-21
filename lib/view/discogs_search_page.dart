import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../data/models/discogs_search_response.dart';
import '../domain/repositories/discogs_repository.dart';

class DiscogsSearchPage extends StatefulWidget {
  const DiscogsSearchPage({super.key});

  @override
  State<DiscogsSearchPage> createState() => _DiscogsSearchPageState();
}

class _DiscogsSearchPageState extends State<DiscogsSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DiscogsSearchItem> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<DiscogsRepository>();
      final results = await repo.searchDiscogs(_searchController.text.trim());
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = '검색 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Discogs 앨범 검색'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _searchController,
                      placeholder: '앨범명/아티스트 입력',
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: CupertinoColors.activeBlue,
                    onPressed: _search,
                    child: const Text('검색',
                        style: TextStyle(color: CupertinoColors.white)),
                  ),
                ],
              ),
            ),
            if (_isLoading) const CupertinoActivityIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_error!,
                    style: const TextStyle(color: CupertinoColors.systemRed)),
              ),
            if (!_isLoading && _results.isEmpty && _error == null)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('검색 결과가 없습니다.'),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, idx) {
                  final album = _results[idx];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, album),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(album.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          if (album.year != null)
                            Text('${album.year}',
                                style: const TextStyle(fontSize: 12)),
                          if (album.label.isNotEmpty)
                            Text(album.label.join(', '),
                                style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
