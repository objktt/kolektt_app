// views/analytics_section.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:kolektt/model/local/collection_record.dart';
import 'package:provider/provider.dart';

import '../components/decade_distribution_view.dart';
import '../components/genre_distribution_view.dart';
import '../view_models/analytics_vm.dart';
import 'common_card.dart';
import '../view/profile/profile_view.dart';

class AnalyticsSection extends StatefulWidget {
  // 컬렉션의 DiscogsRecord 리스트를 입력받습니다.
  final List<CollectionRecord> records;

  const AnalyticsSection({super.key, required this.records});

  @override
  _AnalyticsSectionState createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 프레임 완료 후 viewmodel에 컬렉션 분석 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsViewModel>(context, listen: false)
          .analyzeRecords(widget.records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsViewModel>(
      builder: (context, analyticsVM, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: analyticsVM.hasData && analyticsVM.analytics != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Records Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "나의 레코드",
                            style: const FigmaTextStyles()
                                .headingheading2
                                .copyWith(color: FigmaColors.grey100),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              // 이미 내 프로필 화면이면 push하지 않음
                              final isCurrentProfile =
                                  ModalRoute.of(context)?.settings.name ==
                                      'ProfileView';
                              if (!isCurrentProfile) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const ProfileView(),
                                    settings: const RouteSettings(
                                        name: 'ProfileView'),
                                  ),
                                );
                              }
                            },
                            child: CommonCard(
                              color: const Color(0xFF0036FF),
                              radius: 16,
                              border: Border.all(color: FigmaColors.primary30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 'Analyzed by Kolektt' 텍스트 제거
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox.shrink(),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${analyticsVM.analytics!.totalRecords}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '장',
                                              style: const FigmaTextStyles()
                                                  .headingheading3
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // Most Genre Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "나의 최고 장르",
                            style: const FigmaTextStyles()
                                .headingheading2
                                .copyWith(color: FigmaColors.grey100),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              // 이미 내 프로필 화면이면 push하지 않음
                              final isCurrentProfile =
                                  ModalRoute.of(context)?.settings.name ==
                                      'ProfileView';
                              if (!isCurrentProfile) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const ProfileView(),
                                    settings: const RouteSettings(
                                        name: 'ProfileView'),
                                  ),
                                );
                              }
                            },
                            child: CommonCard(
                              color: FigmaColors.primary10,
                              radius: 16,
                              border: Border.all(color: FigmaColors.primary30),
                              child: GenreDistributionView(
                                  genres: analyticsVM.analytics!.genres),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // Favorite Artists Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "나의 최고 아티스트",
                            style: const FigmaTextStyles()
                                .headingheading2
                                .copyWith(color: FigmaColors.grey100),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              // 이미 내 프로필 화면이면 push하지 않음
                              final isCurrentProfile =
                                  ModalRoute.of(context)?.settings.name ==
                                      'ProfileView';
                              if (!isCurrentProfile) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const ProfileView(),
                                    settings: const RouteSettings(
                                        name: 'ProfileView'),
                                  ),
                                );
                              }
                            },
                            child: CommonCard(
                              color: FigmaColors.primary10,
                              radius: 16,
                              border: Border.all(color: FigmaColors.primary30),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    analyticsVM.analytics!.artists.length,
                                itemBuilder: (context, index) {
                                  final artist =
                                      analyticsVM.analytics!.artists[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              artist.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${artist.count} Albums",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: FigmaColors.primary60,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // Collection Period Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "나의 시대별 컬렉션",
                            style: const FigmaTextStyles()
                                .headingheading2
                                .copyWith(color: FigmaColors.grey100),
                          ),
                          const SizedBox(height: 16),
                          CommonCard(
                            color: FigmaColors.primary10,
                            radius: 16,
                            border: Border.all(color: FigmaColors.primary30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "My favorite era",
                                      style: const FigmaTextStyles()
                                          .headingheading3
                                          .copyWith(color: FigmaColors.grey100),
                                    ),
                                    Text(
                                      "${analyticsVM.analytics!.oldestRecord}~${analyticsVM.analytics!.newestRecord}",
                                      style: const FigmaTextStyles()
                                          .headingheading2
                                          .copyWith(color: FigmaColors.grey100),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 150,
                                  child: DecadeDistributionView(
                                      decades: analyticsVM.analytics!.decades),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.music_note_list,
                        size: 48,
                        color: CupertinoColors.activeBlue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "컬렉션을 추가하여\n분석을 시작해보세요",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
