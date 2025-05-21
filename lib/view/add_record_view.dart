import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kolektt/view/content_view.dart'; // ContentView가 홈화면이라고 가정
import 'package:provider/provider.dart';
import '../view_models/collection_vm.dart';
import 'package:kolektt/data/repositories/supabase_storage_repository_impl.dart';
import 'package:kolektt/main.dart'; // navigatorKey import
// import 'package:flutter/material.dart';

class AddRecordView extends StatefulWidget {
  final Function(
    String title,
    String artist,
    int? year,
    String genre,
    String notes,
    int? price,
    String condition,
    File? image,
    String? coverImage,
    String? catalogNumber,
    String? label,
    String? format,
    String? country,
    String? style,
    String? conditionNotes,
    List<String>? tags,
  ) onSave;

  const AddRecordView({super.key, required this.onSave});

  @override
  _AddRecordViewState createState() => _AddRecordViewState();
}

class _AddRecordViewState extends State<AddRecordView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _catalogNumberController;
  late TextEditingController _labelController;
  late TextEditingController _formatController;
  late TextEditingController _countryController;
  late TextEditingController _styleController;
  late TextEditingController _conditionNotesController;
  late TextEditingController _tagController;
  String _selectedCondition = "NM";
  File? _selectedImage;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _yearController = TextEditingController();
    _genreController = TextEditingController();
    _notesController = TextEditingController();
    _priceController = TextEditingController();
    _catalogNumberController = TextEditingController();
    _labelController = TextEditingController();
    _formatController = TextEditingController();
    _countryController = TextEditingController();
    _styleController = TextEditingController();
    _conditionNotesController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _catalogNumberController.dispose();
    _labelController.dispose();
    _formatController.dispose();
    _countryController.dispose();
    _styleController.dispose();
    _conditionNotesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    int? year = int.tryParse(_yearController.text.trim());
    int? price = int.tryParse(_priceController.text.trim());
    String? coverImageUrl;
    if (_selectedImage != null) {
      final storageRepo = SupabaseStorageRepository();
      coverImageUrl = await storageRepo.uploadImage(_selectedImage!);
      if (coverImageUrl.isEmpty) coverImageUrl = null;
    }
    widget.onSave(
      _titleController.text.trim(),
      _artistController.text.trim(),
      year,
      _genreController.text.trim(),
      _notesController.text.trim(),
      price,
      _selectedCondition,
      _selectedImage,
      coverImageUrl,
      _catalogNumberController.text.trim(),
      _labelController.text.trim(),
      _formatController.text.trim(),
      _countryController.text.trim(),
      _styleController.text.trim(),
      _conditionNotesController.text.trim(),
      _tags,
    );
    await context.read<CollectionViewModel>().fetch();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    navigatorKey.currentState?.pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const ContentView()),
      (route) => false,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // 실제 인식 API 연동 전 임시 딜레이(1.5초)
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _conditionLabel(String code) {
    switch (code) {
      case 'M':
        return 'Mint';
      case 'NM':
        return 'Near Mint';
      case 'VG+':
        return 'Very Good+';
      case 'VG':
        return 'Very Good';
      case 'G+':
        return 'Good+';
      case 'G':
        return 'Good';
      case 'F':
        return 'Fair';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF2D3748);
    const Color lightGrey = Color(0xFFEDF2F7);
    const Color borderColor = Color(0xFFE0E0E5);
    const labelStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xFF0E0E10),
      height: 24 / 14,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "수동 입력",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        previousPageTitle: "기록",
        backgroundColor: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: lightGrey,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Center(
                child: Column(
                  children: [
                    _selectedImage == null
                        ? Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.photo,
                              size: 48,
                              color: CupertinoColors.systemGrey,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(height: 8),
                    CupertinoButton.filled(
                      onPressed: _pickImage,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      child: const Text(
                        '이미지 등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      color: CupertinoColors.inactiveGray,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      onPressed: null,
                      child: const Text('Discogs 앨범 검색(개발중)',
                          style: TextStyle(color: CupertinoColors.white)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Discogs 앨범 검색 기능은 현재 개발중입니다.',
                      style: TextStyle(
                          color: CupertinoColors.systemGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('앨범명', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: '앨범명',
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
                  const SizedBox(height: 24),
                  const Text('아티스트', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _artistController,
                    placeholder: '아티스트',
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
                  const SizedBox(height: 24),
                  const Text('발매년도', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _yearController,
                    placeholder: '발매년도',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('장르', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _genreController,
                    placeholder: '장르',
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
                  const SizedBox(height: 24),
                  const Text('카탈로그 번호', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _catalogNumberController,
                    placeholder: '카탈로그 번호',
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
                  const SizedBox(height: 24),
                  const Text('레이블', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _labelController,
                    placeholder: '레이블',
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
                  const SizedBox(height: 24),
                  const Text('포맷', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _formatController,
                    placeholder: '포맷',
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
                  const SizedBox(height: 24),
                  const Text('국가', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _countryController,
                    placeholder: '국가',
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
                  const SizedBox(height: 24),
                  const Text('스타일', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _styleController,
                    placeholder: '스타일',
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
                  const SizedBox(height: 24),
                  const Text('가격', style: labelStyle),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('상태', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoButton(
                    padding: const EdgeInsets.all(12),
                    color: CupertinoColors.systemGrey5,
                    onPressed: () async {
                      await showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return CupertinoActionSheet(
                            title: const Text('상태 선택'),
                            actions: [
                              ...['M', 'NM', 'VG+', 'VG', 'G+', 'G', 'F']
                                  .map((code) => CupertinoActionSheetAction(
                                        child: Text(_conditionLabel(code)),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCondition = code;
                                          });
                                          Navigator.pop(context);
                                        },
                                      )),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('취소'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          );
                        },
                      );
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(_conditionLabel(_selectedCondition)),
                  ),
                  const SizedBox(height: 24),
                  const Text('상태 메모', style: labelStyle),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('노트', style: labelStyle),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    controller: _notesController,
                    placeholder: '노트',
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
                  const SizedBox(height: 24),
                  // 태그 입력
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _tagController,
                          placeholder: '태그 추가 (Enter)',
                          onSubmitted: (_) => _addTag(),
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
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: _addTag,
                        child: const Icon(CupertinoIcons.add_circled),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
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
                                        onTap: () => _removeTag(tag),
                                        child: const Icon(
                                            CupertinoIcons.clear_circled_solid,
                                            size: 16),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: _saveRecord,
                    child: const Text('저장'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
