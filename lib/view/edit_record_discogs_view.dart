import 'dart:io';

import 'package:flutter/cupertino.dart';
import '../domain/entities/collection_entry.dart';

class EditRecordDiscogsView extends StatefulWidget {
  final CollectionEntry entry;
  final Function(CollectionEntry updated) onSave;
  final Function(int recordId) onDelete;

  const EditRecordDiscogsView({
    super.key,
    required this.entry,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditRecordDiscogsView> createState() => _EditRecordDiscogsViewState();
}

class _EditRecordDiscogsViewState extends State<EditRecordDiscogsView> {
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _conditionNotesController;
  late List<String> _tags;
  String _selectedCondition = '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _notesController = TextEditingController(text: e.notes);
    _priceController = TextEditingController(text: e.purchasePrice.toString());
    _conditionNotesController = TextEditingController(text: e.conditionNotes);
    _tags = List<String>.from(e.tags);
    _selectedCondition = e.condition;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    _conditionNotesController.dispose();
    super.dispose();
  }

  void _onSave() {
    final updated = CollectionEntry(
      recordId: widget.entry.recordId,
      title: widget.entry.title, // readOnly
      artist: widget.entry.artist, // readOnly
      year: widget.entry.year, // readOnly
      genre: widget.entry.genre, // readOnly
      coverImage: widget.entry.coverImage, // readOnly
      catalogNumber: widget.entry.catalogNumber, // readOnly
      label: widget.entry.label, // readOnly
      format: widget.entry.format, // readOnly
      country: widget.entry.country, // readOnly
      style: widget.entry.style, // readOnly
      condition: _selectedCondition,
      conditionNotes: _conditionNotesController.text.trim(),
      purchasePrice: double.tryParse(_priceController.text.trim()) ?? 0,
      purchaseDate: widget.entry.purchaseDate,
      notes: _notesController.text.trim(),
      tags: _tags,
      source: widget.entry.source,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  void _onDelete() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        content: const Text('이 앨범은 복구할 수 없습니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('삭제'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      widget.onDelete(widget.entry.recordId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Discogs 앨범 정보'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '이 정보는 Discogs에서 받아온 데이터입니다.\n주요 정보는 수정할 수 없습니다.\n필요시 메모, 상태, 가격, 태그만 수정 가능합니다.',
                  style: TextStyle(
                    color: CupertinoColors.systemYellow,
                    fontSize: 14,
                  ),
                ),
              ),
              // 주요 정보(읽기 전용)
              _buildReadOnlyField('앨범명', widget.entry.title),
              _buildReadOnlyField('아티스트', widget.entry.artist),
              _buildReadOnlyField('발매년도', widget.entry.year?.toString() ?? ''),
              _buildReadOnlyField('장르', widget.entry.genre),
              _buildReadOnlyField('레이블', widget.entry.label),
              _buildReadOnlyField('포맷', widget.entry.format),
              _buildReadOnlyField('국가', widget.entry.country),
              _buildReadOnlyField('스타일', widget.entry.style),
              _buildReadOnlyField('카탈로그 번호', widget.entry.catalogNumber),
              _buildReadOnlyField('커버 이미지 URL', widget.entry.coverImage),
              const SizedBox(height: 16),
              // 수정 가능 필드
              const Text('가격',
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              CupertinoTextField(
                controller: _priceController,
                placeholder: '가격',
                keyboardType: TextInputType.number,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              const Text('상태 메모',
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              CupertinoTextField(
                controller: _conditionNotesController,
                placeholder: '상태 메모',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              const Text('메모',
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              CupertinoTextField(
                controller: _notesController,
                placeholder: '메모',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              // 태그 입력(간단 구현)
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      placeholder: '태그 추가 (Enter)',
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            _tags.add(value.trim());
                          });
                        }
                      },
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey5,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(tag),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tags.remove(tag);
                                        });
                                      },
                                      child: const Icon(
                                          CupertinoIcons.clear_circled_solid,
                                          size: 16),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: _onSave,
                child: const Text('저장'),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: _onDelete,
                child: const Text('삭제',
                    style: TextStyle(color: CupertinoColors.destructiveRed)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        CupertinoTextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          padding: const EdgeInsets.all(12),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
