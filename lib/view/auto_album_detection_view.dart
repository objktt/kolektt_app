import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../view_models/collection_vm.dart';
import 'add_collection_view.dart';
import 'add_record_view.dart';

enum MediaType { cover, cd }

class AutoAlbumDetectionScreen extends StatefulWidget {
  const AutoAlbumDetectionScreen({super.key});

  @override
  State<AutoAlbumDetectionScreen> createState() =>
      _AutoAlbumDetectionScreenState();
}

class _AutoAlbumDetectionScreenState extends State<AutoAlbumDetectionScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isLoading = false;
  MediaType _selectedMediaType = MediaType.cover;
  String? _errorMessage;
  bool _hasResult = false;
  AnimationController? _lottieController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _lottieController = AnimationController(vsync: this);
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = '카메라 권한이 필요합니다.';
      });
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = '카메라를 찾을 수 없습니다.';
      });
      return;
    }
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _lottieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0036FF);
    final Color backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemBackground,
      context,
    );
    final Color textColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    return Consumer<CollectionViewModel>(
      builder: (context, collectionVM, child) {
        if (_hasResult) {
          return CupertinoPageScaffold(
            backgroundColor: backgroundColor,
            navigationBar: _buildNavigationBar(context),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: _buildResultsList(collectionVM)),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: CupertinoButton(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _hasResult = false;
                                    });
                                  },
                                  child: const Text(
                                    '다시 촬영',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: CupertinoButton(
                                  color: CupertinoColors.systemGrey4,
                                  borderRadius: BorderRadius.circular(8),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => AddRecordView(
                                            onSave: _onManualInputSave),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '수동입력',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: _buildNavigationBar(context),
          child: SafeArea(
            child: Stack(
              children: [
                _buildCameraView(context),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemBackground,
                        context,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/images/loading_animation.json',
                              width: 300,
                              height: 300,
                              repeat: true,
                              controller: _lottieController,
                              onLoaded: (composition) {
                                _lottieController?.duration =
                                    composition.duration * 2;
                                _lottieController?.repeat();
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '앨범을 인식 중이에요',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.label,
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI가 앨범 정보를 분석하고 있어요',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaTab(MediaType type, String label, IconData icon) {
    final bool selected = _selectedMediaType == type;
    final Color color = selected ? Colors.white : Colors.white.withOpacity(0.5);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMediaType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGuideText(MediaType type) {
    switch (type) {
      case MediaType.cover:
        return '앨범 커버를 사각 프레임에 맞춰주세요.';
      case MediaType.cd:
        return 'CD·카세트 앞면을 프레임에 맞춰주세요.';
    }
  }

  void _onShutterPressed() async {
    if (!_isCameraInitialized ||
        _isTakingPicture ||
        _cameraController == null) {
      return;
    }
    setState(() {
      _isTakingPicture = true;
      _isLoading = true;
    });
    try {
      final XFile file = await _cameraController!.takePicture();
      final collectionVM = context.read<CollectionViewModel>();
      await collectionVM.recognizeAlbum(File(file.path));
      setState(() {
        _hasResult = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '촬영 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isTakingPicture = false;
        _isLoading = false;
      });
    }
  }

  void _onManualInputSave(
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
  ) async {
    final collectionVM = context.read<CollectionViewModel>();
    await collectionVM.addRecord(
      title: title,
      artist: artist,
      year: year,
      genre: genre,
      notes: notes,
      price: price,
      condition: condition,
      image: image,
      coverImage: coverImage,
      catalogNumber: catalogNumber,
      label: label,
      format: format,
      country: country,
      style: style,
      conditionNotes: conditionNotes,
      tags: tags,
    );
  }

  CupertinoNavigationBar _buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: const Text('앨범인식'),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text("취소"),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildResultsList(CollectionViewModel vm) {
    if (!vm.isLoading && vm.errorMessage == null && vm.searchResults.isEmpty) {
      return const Center(
        child: Text(
          '인식된 앨범이 없습니다.\n사진 촬영 후 결과가 여기 표시됩니다.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final record = vm.searchResults[index];
        return _buildResultItem(record);
      },
    );
  }

  Widget _buildResultItem(record) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToAddToCollection(record),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CupertinoColors.systemGrey4),
            ),
          ),
          child: Row(
            children: [
              _buildRecordImage(record),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(CupertinoIcons.add),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordImage(record) {
    if (record.coverImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: record.coverImage,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(CupertinoIcons.music_note),
      );
    }
  }

  void _navigateToAddToCollection(record) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => AddCollectionView(record: record),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.9,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (!_isCameraInitialized ||
                            _cameraController == null ||
                            !_cameraController!.value.isInitialized) {
                          return const Center(
                              child: CupertinoActivityIndicator());
                        }
                        return SizedBox.expand(
                          child: CameraPreview(_cameraController!),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMediaTab(
                                MediaType.cover, '커버인식', CupertinoIcons.square),
                            _buildMediaTab(MediaType.cd, 'CD·카세트',
                                CupertinoIcons.cube_fill),
                          ],
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            _getGuideText(_selectedMediaType),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: CupertinoColors.label,
              shadows: [
                Shadow(
                    color: CupertinoColors.white.withOpacity(0.7),
                    blurRadius: 4)
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final collectionVM = context.read<CollectionViewModel>();
                      await collectionVM.recognizeAlbum(File(pickedFile.path));
                      setState(() {
                        _isLoading = false;
                        _hasResult = true;
                      });
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                        _errorMessage = '이미지 업로드 중 오류가 발생했습니다.';
                      });
                    }
                  }
                },
                child: const Column(
                  children: [
                    Icon(CupertinoIcons.photo_on_rectangle,
                        size: 28, color: CupertinoColors.systemGrey),
                    SizedBox(height: 2),
                    Text(
                      '갤러리',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isCameraInitialized && !_isTakingPicture
                    ? () {
                        _onShutterPressed();
                      }
                    : null,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isCameraInitialized && !_isTakingPicture
                        ? const Color(0xFF0036FF)
                        : CupertinoColors.systemGrey4,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.camera,
                    color: CupertinoColors.white,
                    size: 32,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) =>
                            AddRecordView(onSave: _onManualInputSave),
                      ));
                },
                child: const Column(
                  children: [
                    Icon(CupertinoIcons.pencil,
                        size: 28, color: CupertinoColors.systemGrey),
                    SizedBox(height: 2),
                    Text(
                      '수동입력',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
