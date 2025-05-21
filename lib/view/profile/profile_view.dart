import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kolektt/components/seller_row.dart';
import 'package:kolektt/figma_colors.dart';
import 'package:kolektt/view_models/profile_vm.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../components/analytics_section.dart';
import '../../components/collection_grid_item.dart';
import '../../main.dart';
import '../../model/local/collection_record.dart';
import '../../model/supabase/profile.dart';
import '../../model/supabase/user_stats.dart';
import '../../view_models/auth_vm.dart';
import '../../view_models/collection_vm.dart';
import '../SettingsView.dart';
import '../login_view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  // 프로필 데이터
  String displayName = '';
  String genre = '';
  int recordCount = 0;
  int followingCount = 0;
  int followerCount = 0;
  int totalRecords = 0;
  int totalSales = 0;

  // 상태 관리
  bool isLoadingProfile = false;
  bool _isRefreshing = false;
  String? errorMessage;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadProfileData();
    } catch (e) {
      debugPrint('리프레시 오류: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoadingProfile = true;
      errorMessage = null;
    });

    try {
      final auth = context.read<AuthViewModel>();
      final profile = context.read<ProfileViewModel>();
      final collection = context.read<CollectionViewModel>();

      await auth.fetchCurrentUser();
      await profile.fetchAll();
      await collection.fetch();

      final Profiles profileData = auth.profiles!;

      setState(() {
        displayName = profileData.display_name ?? '익명';
        genre = profileData.genre ?? '장르 정보 없음';
      });

      UserStats statsData = auth.userStats;

      setState(() {
        recordCount = statsData.record_count;
        followingCount = statsData.following_count;
        followerCount = statsData.follower_count;
        totalRecords = statsData.total_records;
        totalSales = statsData.total_sales;
      });
    } catch (e) {
      setState(() {
        errorMessage = '프로필 로드 오류: $e';
      });
    } finally {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final collection = context.read<CollectionViewModel>();
    final user = auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const LoginView()),
        );
      });
      return const SizedBox();
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(
              key: _refreshKey,
              onRefresh: _handleRefresh,
              builder: (
                BuildContext context,
                RefreshIndicatorMode refreshState,
                double pulledExtent,
                double refreshTriggerPullDistance,
                double refreshIndicatorExtent,
              ) {
                return Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (refreshState == RefreshIndicatorMode.refresh ||
                          refreshState == RefreshIndicatorMode.armed)
                        const CupertinoActivityIndicator(
                          radius: 14.0,
                          color: CupertinoColors.activeBlue,
                        ),
                      if (refreshState == RefreshIndicatorMode.drag)
                        Transform.rotate(
                          angle: (pulledExtent / refreshTriggerPullDistance) *
                              2 *
                              3.14159,
                          child: Icon(
                            CupertinoIcons.arrow_down,
                            color: CupertinoColors.systemGrey.withOpacity(
                              pulledExtent / refreshTriggerPullDistance,
                            ),
                            size: 24,
                          ),
                        ),
                      if (refreshState == RefreshIndicatorMode.done)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 0.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: const Icon(
                                CupertinoIcons.check_mark,
                                color: CupertinoColors.activeGreen,
                                size: 24,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isRefreshing ? 0.5 : 1.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("프로필",
                              style: const FigmaTextStyles()
                                  .displaydisplay2
                                  .copyWith(color: FigmaColors.grey100)),
                          IconButton(
                              icon: const Icon(CupertinoIcons.gear,
                                  color: CupertinoColors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const SettingsView(),
                                  ),
                                );
                              },
                              iconSize: 32)
                        ],
                      ),
                    ),
                    _buildProfile(
                      displayName,
                      genre,
                    ),
                    AnalyticsSection(records: collection.collectionRecords),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(String name, String genre) {
    final profileImage = context.watch<AuthViewModel>().profiles?.profile_image;

    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Profile Image with Edit Button
                Stack(
                  children: [
                    profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: FadeInImage.memoryNetwork(
                              width: 86,
                              height: 86,
                              placeholder: kTransparentImage,
                              image: profileImage,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 86,
                                  height: 86,
                                  color: CupertinoColors.systemGrey5,
                                  child: const Icon(
                                    CupertinoIcons.person_alt_circle,
                                    color: CupertinoColors.systemGrey2,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            CupertinoIcons.person_alt_circle,
                            size: 86,
                            color: primaryColor,
                          ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: FigmaColors.primary70,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: GestureDetector(
                          onTap: () {
                            final auth = context.read<AuthViewModel>();
                            if (isLoadingProfile) {
                              return;
                            }

                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => const EditProfileView(),
                              ),
                            ).then((value) async {
                              await auth.fetchProfile();
                              _loadProfileData();
                            });
                          },
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: CupertinoColors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 17),
                // Name and Genre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const FigmaTextStyles()
                            .headingheading2
                            .copyWith(color: FigmaColors.grey100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        genre,
                        style: const FigmaTextStyles()
                            .bodyxs
                            .copyWith(color: FigmaColors.grey50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profileImage = context.watch<AuthViewModel>().profiles?.profile_image;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: CupertinoColors.systemGrey.withOpacity(0.1),
              child: profileImage != null
                  ? ClipOval(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: profileImage,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: CupertinoColors.systemGrey5,
                            child: const Icon(
                              CupertinoIcons.person_alt_circle,
                              color: CupertinoColors.systemGrey2,
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 70,
                      color: primaryColor,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            genre,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(recordCount.toString(), "레코드"),
              _buildVerticalDivider(),
              _buildStatItem(followingCount.toString(), "팔로잉"),
              _buildVerticalDivider(),
              _buildStatItem(followerCount.toString(), "팔로워"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildStatCard(
            icon: CupertinoIcons.music_note,
            value: totalRecords.toString(),
            label: "총 레코드",
            isPrimary: true,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: CupertinoIcons.money_dollar,
            value: "${(totalSales / 10000).toStringAsFixed(1)}만원",
            label: "총 판매액",
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isPrimary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? primaryColor.withOpacity(0.3)
                  : CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isPrimary ? CupertinoColors.white : primaryColor,
              size: 30,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                color:
                    isPrimary ? CupertinoColors.white : CupertinoColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? CupertinoColors.white.withOpacity(0.8)
                    : CupertinoColors.systemGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: CupertinoColors.systemGrey4,
    );
  }

  Widget _buildCollectionTab() {
    final model = context.watch<CollectionViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: model.collectionRecords.length,
        itemBuilder: (context, index) {
          CollectionRecord record = model.collectionRecords[index];
          record.record.resourceUrl =
              "https://api.discogs.com/releases/${record.record.id}";
          return buildGridItem(context, record, model);
        },
      ),
    );
  }

  Widget _buildSaleTab() {
    final profile = context.watch<ProfileViewModel>();
    final mySales = profile.mySales;

    return Column(
      children: [
        if (profile.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CupertinoActivityIndicator(),
          ),
        if (profile.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              profile.errorMessage!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        if (!profile.isLoading && mySales.salesListing.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "판매중인 상품이 없습니다.",
              style: TextStyle(
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        if (!profile.isLoading && mySales.salesListing.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                mySales.salesListing.length,
                (index) {
                  return GestureDetector(
                    onTap: () {},
                    onLongPress: () {
                      _showDeleteDialog(mySales.salesListing[index].id);
                    },
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SellerRow(
                            sellerName:
                                mySales.profiles[index].display_name.toString(),
                            price: mySales.salesListing[index].price.toInt(),
                            condition: mySales.salesListing[index].condition,
                            onPurchase: () {})),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPurchaseTab() {
    final profile = context.watch<ProfileViewModel>();
    final myPurchases = profile.myPurchases;

    if (profile.isLoading) {
      return const CupertinoActivityIndicator();
    }

    if (profile.errorMessage != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            profile.errorMessage!,
            style: const TextStyle(
              color: CupertinoColors.systemRed,
            ),
          ),
        ),
      );
    }

    if (myPurchases.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            "구매한 상품이 없어요.",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(myPurchases.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SellerRow(
            sellerName:
                myPurchases[index].seller_profile.display_name.toString(),
            price: myPurchases[index].purchase.price,
            condition: "",
            onPurchase: () {},
          ),
        );
      }),
    );
  }

  Widget _buildWidget(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: child,
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("판매 취소"),
          content: const Text("판매를 취소하시겠습니까?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("취소"),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                context.read<ProfileViewModel>().deleteSale(id);
                Navigator.pop(context);
              },
              child: const Text("취소하기"),
            ),
          ],
        );
      },
    );
  }
}
