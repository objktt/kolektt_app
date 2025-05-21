import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../view_models/search_vm.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchTextChanged;
  final String selectedGenre;
  final ValueChanged<String> onGenreChanged;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortOptionChanged;
  final List<String> genres;

  const SearchFilterBar({super.key, 
    required this.searchText,
    required this.onSearchTextChanged,
    required this.selectedGenre,
    required this.onGenreChanged,
    required this.sortOption,
    required this.onSortOptionChanged,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CupertinoTextField(
            placeholder: "앨범 또는 아티스트 검색",
            prefix: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
            ),
            onChanged: onSearchTextChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              DropdownButton<String>(
                value: selectedGenre,
                items: genres
                    .map((genre) => DropdownMenuItem(value: genre, child: Text(genre)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onGenreChanged(value);
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<SortOption>(
                value: sortOption,
                items: SortOption.values
                    .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option.name),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onSortOptionChanged(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
