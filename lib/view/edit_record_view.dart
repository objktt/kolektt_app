import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../domain/entities/collection_entry.dart';

class EditRecordView extends StatefulWidget {
  final CollectionEntry entry;
  final Function(CollectionEntry updated) onSave;
  final Function(int recordId) onDelete;

  const EditRecordView(
      {super.key,
      required this.entry,
      required this.onSave,
      required this.onDelete});

  @override
  State<EditRecordView> createState() => _EditRecordViewState();
}

class _EditRecordViewState extends State<EditRecordView> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _coverImageController;
  late TextEditingController _catalogNumberController;
  late TextEditingController _labelController;
  late TextEditingController _formatController;
  late TextEditingController _countryController;
  late TextEditingController _styleController;
  late TextEditingController _conditionNotesController;
  late List<String> _tags;
  String _selectedCondition = '';
  File? _selectedImage;
  static const Color borderColor = Color(0xFFE0E0E5);

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: Color(0xFF0E0E10),
    height: 24 / 14,
  );

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleController = TextEditingController(text: e.title);
    _artistController = TextEditingController(text: e.artist);
    _yearController = TextEditingController(text: e.year?.toString() ?? '');
    _genreController = TextEditingController(text: e.genre);
    _notesController = TextEditingController(text: e.notes);
    _priceController = TextEditingController(text: e.purchasePrice.toString());
    _coverImageController = TextEditingController(text: e.coverImage);
    _catalogNumberController = TextEditingController(text: e.catalogNumber);
    _labelController = TextEditingController(text: e.label);
    _formatController = TextEditingController(text: e.format);
    _countryController = TextEditingController(text: e.country);
    _styleController = TextEditingController(text: e.style);
    _conditionNotesController = TextEditingController(text: e.conditionNotes);
    _tags = List<String>.from(e.tags);
    _selectedCondition = e.condition;
    // _selectedImage는 별도 구현 필요(이미지 수정 지원 시)
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _coverImageController.dispose();
    _catalogNumberController.dispose();
    _labelController.dispose();
    _formatController.dispose();
    _countryController.dispose();
    _styleController.dispose();
    _conditionNotesController.dispose();
    super.dispose();
  }

  void _onSave() {
    final updated = CollectionEntry(
      recordId: widget.entry.recordId,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      year: int.tryParse(_yearController.text.trim()),
      genre: _genreController.text.trim(),
      coverImage: _coverImageController.text.trim(),
      catalogNumber: _catalogNumberController.text.trim(),
      label: _labelController.text.trim(),
      format: _formatController.text.trim(),
      country: _countryController.text.trim(),
      style: _styleController.text.trim(),
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
        middle: Text('앨범 정보 수정'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 앨범명
              Text('앨범명', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _titleController,
                placeholder: '앨범명',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 아티스트
              Text('아티스트', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _artistController,
                placeholder: '아티스트',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 발매년도
              Text('발매년도', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _yearController,
                placeholder: '발매년도',
                keyboardType: TextInputType.number,
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 장르
              Text('장르', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _genreController,
                placeholder: '장르',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 커버 이미지 URL
              Text('커버 이미지 URL', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _coverImageController,
                placeholder: '커버 이미지 URL',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 카탈로그 번호
              Text('카탈로그 번호', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _catalogNumberController,
                placeholder: '카탈로그 번호',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 레이블
              Text('레이블', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _labelController,
                placeholder: '레이블',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 포맷
              Text('포맷', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _formatController,
                placeholder: '포맷',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 국가
              Text('국가', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _countryController,
                placeholder: '국가',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 스타일
              Text('스타일', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _styleController,
                placeholder: '스타일',
                readOnly: widget.entry.source != 'manual',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 가격
              Text('가격', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _priceController,
                placeholder: '가격',
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 상태 메모
              Text('상태 메모', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _conditionNotesController,
                placeholder: '상태 메모',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 메모
              Text('메모', style: labelStyle),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _notesController,
                placeholder: '메모',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                placeholderStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFFB7B7B8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              // 태그 입력(간단 구현)
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      placeholder: '태그 추가 (Enter)',
                      onSubmitted: widget.entry.source == 'manual'
                          ? (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  _tags.add(value.trim());
                                });
                              }
                            }
                          : null,
                      readOnly: widget.entry.source != 'manual',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      placeholderStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFFB7B7B8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                                      onTap: widget.entry.source == 'manual'
                                          ? () {
                                              setState(() {
                                                _tags.remove(tag);
                                              });
                                            }
                                          : null,
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
}
