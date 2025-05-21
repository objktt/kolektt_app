import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart'; // 미사용 import 제거
import 'package:kolektt/data/models/discogs_search_response.dart';
import 'package:provider/provider.dart';

import '../domain/entities/record_condition.dart';
import '../view_models/add_collection_vm.dart';
import '../view_models/collection_vm.dart';

class AddCollectionView extends StatefulWidget {
  final DiscogsSearchItem record;

  const AddCollectionView({
    super.key,
    required this.record,
  });

  @override
  State<AddCollectionView> createState() => _AddCollectionViewState();
}

class _AddCollectionViewState extends State<AddCollectionView> {
  void _showConditionPicker() {
    final model = context.read<AddCollectionViewModel>();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('상태 선택'),
          message: const Text('원하는 상태를 선택해주세요.'),
          actions: RecordCondition.values.map((option) {
            return CupertinoActionSheetAction(
              child: Text(option.name),
              onPressed: () {
                setState(() {
                  model.selectedCondition = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('취소'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final model = context.read<AddCollectionViewModel>();
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: isDark
                ? CupertinoColors.systemBackground.darkColor
                : CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? CupertinoColors.systemBackground.darkColor
                      : CupertinoColors.systemBackground,
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
                            color: isDark
                                ? CupertinoColors.systemRed
                                : CupertinoColors.systemRed),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: Text(
                        '확인',
                        style: TextStyle(
                            color: isDark
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemBlue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: model.purchaseDate,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    setState(() {
                      model.purchaseDate = date;
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

  Widget _buildEditableTag(String tag) {
    final model = context.read<AddCollectionViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4,
        border: Border.all(color: CupertinoColors.systemGrey),
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
                model.tagList.remove(tag);
              });
            },
            child: const Icon(
              CupertinoIcons.clear,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getInputDecoration() {
    return BoxDecoration(
      color: CupertinoColors.systemGrey6,
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AddCollectionViewModel>().record = widget.record;
  }

  @override
  void dispose() {
    final model = context.read<AddCollectionViewModel>();
    model.notesController.dispose();
    model.priceController.dispose();
    model.newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionVM = context.watch<AddCollectionViewModel>();
    const Color borderColor = Color(0xFFE0E0E5);
    const labelStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xFF0E0E10),
      height: 24 / 14,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('컬렉션에 추가',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('취소',
              style: TextStyle(color: CupertinoColors.systemRed)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 앨범 카드
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildRecordInfo(widget.record),
                ),

                const SizedBox(height: 24),

                // 입력폼 시작
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 가격
                    const Text('가격', style: labelStyle),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: collectionVM.priceController,
                      placeholder: '가격',
                      keyboardType: TextInputType.number,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          '₩',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                    // 상태
                    const Text('상태', style: labelStyle),
                    const SizedBox(height: 6),
                    CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      color: CupertinoColors.systemGrey5,
                      onPressed: _showConditionPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            collectionVM.selectedCondition.name,
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            color: CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 상태 메모
                    const Text('상태 메모', style: labelStyle),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: collectionVM.conditionNotesController,
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
                    // 노트
                    const Text('노트', style: labelStyle),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: collectionVM.notesController,
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
                            controller: collectionVM.newTagController,
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
                    if (collectionVM.tagList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          children: collectionVM.tagList
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
                                              CupertinoIcons
                                                  .clear_circled_solid,
                                              size: 16),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // 저장 버튼 등은 기존대로 유지
                  ],
                ),
                // 입력폼 끝

                const SizedBox(height: 24),

                // 에러 메시지
                if (collectionVM.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      collectionVM.errorMessage!,
                      style: const TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // 추가 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: collectionVM.isAdding
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : CupertinoButton(
                          color: const Color(0xFF0036FF),
                          borderRadius: BorderRadius.circular(8),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            if (collectionVM.price == 0.0) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text('입력 오류'),
                                    content: const Text('유효한 가격을 입력해주세요.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('확인'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            await collectionVM.addToCollection();
                            if (collectionVM.errorMessage == null) {
                              if (!mounted) return;
                              context.read<CollectionViewModel>().fetch();
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          },
                          child: const Text(
                            '컬렉션에 추가',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: CupertinoColors.white,
                              letterSpacing: 0.32,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordInfo(DiscogsSearchItem record) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: record.coverImage.isNotEmpty
              ? Image.network(
                  record.coverImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 80,
                  height: 80,
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(
                    CupertinoIcons.music_note,
                    size: 30,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 4),
              Text(
                '${record.year}년',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addTag() {
    final collectionVM = context.read<AddCollectionViewModel>();
    final tag = collectionVM.newTagController.text.trim();
    if (tag.isNotEmpty && !collectionVM.tagList.contains(tag)) {
      setState(() {
        collectionVM.tagList.add(tag);
        collectionVM.newTagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    final collectionVM = context.read<AddCollectionViewModel>();
    setState(() {
      collectionVM.tagList.remove(tag);
    });
  }
}
