import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/local/collection_record.dart';
import '../../model/supabase/user_collection.dart';

class CollectionEditPage extends StatefulWidget {
  final CollectionRecord collection;
  final Function(UserCollection) onSave;

  const CollectionEditPage({
    super.key,
    required this.collection,
    required this.onSave,
  });

  @override
  _CollectionEditPageState createState() => _CollectionEditPageState();
}

class _CollectionEditPageState extends State<CollectionEditPage> {
  late TextEditingController _conditionNoteController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _notesController;
  late TextEditingController _newTagController; // 새 태그 입력용 컨트롤러

  late String _condition;
  late DateTime? _purchaseDate;

  // 편집 시 태그 목록을 관리할 리스트
  late List<String> _tagList;

  final List<String> _conditionOptions = [
    'Mint (M)',
    'Near Mint (NM)',
    'Very Good Plus (VG+)',
    'Very Good (VG)',
    'Good Plus (G+)',
    'Good (G)',
    'Fair (F)',
    'Poor (P)'
  ];

  /// 각 상태에 따른 색상 매핑
  final Map<String, Color> _conditionColors = {
    'Mint (M)': const Color(0xFF4CAF50),
    'Near Mint (NM)': const Color(0xFF8BC34A),
    'Very Good Plus (VG+)': const Color(0xFFCDDC39),
    'Very Good (VG)': const Color(0xFFFFEB3B),
    'Good Plus (G+)': const Color(0xFFFFC107),
    'Good (G)': const Color(0xFFFF9800),
    'Fair (F)': const Color(0xFFFF5722),
    'Poor (P)': const Color(0xFFE53935),
  };

  @override
  void initState() {
    super.initState();
    _condition =
        widget.collection.user_collection.condition ?? _conditionOptions[0];
    _purchaseDate = widget.collection.user_collection.purchase_date;

    _conditionNoteController = TextEditingController(
      text: widget.collection.user_collection.condition_note ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.collection.user_collection.purchase_price.toString(),
    );
    _notesController = TextEditingController(
      text: widget.collection.user_collection.notes ?? '',
    );
    // 기존 tags를 복사 (null이면 빈 리스트)
    _tagList = List<String>.from(widget.collection.user_collection.tags ?? []);
    _newTagController = TextEditingController();
  }

  @override
  void dispose() {
    _conditionNoteController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final editedCollection = UserCollection(
      id: widget.collection.user_collection.id,
      user_id: widget.collection.user_collection.user_id,
      record_id: widget.collection.user_collection.record_id,
      condition: _condition,
      condition_note: _conditionNoteController.text.isEmpty
          ? ""
          : _conditionNoteController.text,
      purchase_date: _purchaseDate,
      purchase_price: double.tryParse(_purchasePriceController.text) ??
          widget.collection.user_collection.purchase_price,
      notes: _notesController.text.isEmpty ? "" : _notesController.text,
      tags: _tagList,
      source: widget.collection.user_collection.source,
    );

    widget.onSave(editedCollection);
    // 저장 후 필요한 추가 처리가 있다면 이곳에 작성할 수 있습니다.
  }

  void _showDatePicker() {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: isDark
                ? CupertinoColors.systemBackground.darkColor
                : CupertinoColors.systemBackground.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : CupertinoColors.systemBackground.color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE57373) : Colors.red,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF64B5F6) : Colors.blue,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _purchaseDate ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    setState(() {
                      _purchaseDate = date;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConditionPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('상태 선택'),
          actions: _conditionOptions.map((option) {
            return CupertinoActionSheetAction(
              child: Text(option),
              onPressed: () {
                setState(() => _condition = option);
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  // --------------------
  //   편집 모드 위젯 (태그 입력 및 동적 처리)
  // --------------------
  Widget _buildEditMode() {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildFormSection(
            title: '레코드 상태',
            icon: Icons.check_circle,
            child: GestureDetector(
              onTap: _showConditionPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF424242) : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _conditionColors[_condition] ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _condition,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: isDark ? const Color(0xFF9E9E9E) : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFormSection(
            title: '상태 참고사항',
            icon: Icons.notes,
            child: _buildTextField(
              controller: _conditionNoteController,
              placeholder: '상태에 대한 추가 설명',
            ),
          ),
          _buildFormSection(
            title: '구매가',
            icon: Icons.attach_money,
            child: _buildTextField(
              controller: _purchasePriceController,
              placeholder: '구매 가격',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefix: Text(
                '₩',
                style: TextStyle(
                  color: isDark ? const Color(0xFF9E9E9E) : Colors.grey,
                ),
              ),
            ),
          ),
          _buildFormSection(
            title: '구매일',
            icon: Icons.calendar_today,
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF424242) : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _purchaseDate != null
                          ? DateFormat('yyyy년 MM월 dd일').format(_purchaseDate!)
                          : '날짜 선택',
                      style: TextStyle(
                        color: _purchaseDate != null
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? const Color(0xFF9E9E9E) : Colors.grey),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.calendar,
                      color: isDark ? const Color(0xFF9E9E9E) : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFormSection(
            title: '메모',
            icon: Icons.edit_note,
            child: _buildTextField(
              controller: _notesController,
              placeholder: '추가 메모',
              maxLines: 4,
            ),
          ),
          // 태그 입력 섹션 (동적 처리)
          _buildFormSection(
            title: '태그',
            icon: Icons.label,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 현재 태그들을 Container 형태로 보여줌 (삭제 버튼 포함)
                if (_tagList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _tagList.map((tag) {
                      return _buildEditableTag(tag);
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                // 새로운 태그 입력 필드와 추가 버튼
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _newTagController,
                        placeholder: '새 태그 입력',
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Text('추가'),
                      onPressed: () {
                        final newTag = _newTagController.text.trim();
                        if (newTag.isNotEmpty && !_tagList.contains(newTag)) {
                          setState(() {
                            _tagList.add(newTag);
                          });
                          _newTagController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 태그를 편집 모드에서 보여주는 위젯 (Chip 대신 Container 사용)
  Widget _buildEditableTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _tagList.remove(tag);
              });
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefix,
  }) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle:
          TextStyle(color: isDark ? const Color(0xFF9E9E9E) : Colors.grey),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      keyboardType: keyboardType,
      maxLines: maxLines,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefix: prefix,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF333333) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF424242) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? const Color(0xFF9E9E9E) : Colors.grey[600],
                ),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const FigmaTextStyles()
                    .headingheading5
                    .copyWith(color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF64B5F6) : Colors.blue;
    final secondaryColor = isDark ? const Color(0xFFE57373) : Colors.red;

    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: primaryColor,
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                secondary: secondaryColor,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.white,
              primaryColor: primaryColor,
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                secondary: secondaryColor,
              ),
            ),
      child: CupertinoPageScaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]!,
            ),
          ),
          middle: Text(
            '레코드 편집',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _saveChanges,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor,
                  width: 1,
                ),
              ),
              child: Text(
                '저장',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cover and title area
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 220,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [
                                    const Color(0xFF1E1E1E),
                                    const Color(0xFF121212)
                                  ]
                                : [Colors.grey[100]!, Colors.white],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.5 : 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: widget.collection.record.coverImage,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.black : Colors.white)
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  widget.collection.record.title,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 바로 편집 모드 위젯 표시
                _buildEditMode(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
