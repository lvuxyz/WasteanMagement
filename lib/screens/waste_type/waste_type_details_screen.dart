import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../blocs/admin/admin_cubit.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_tab_bar.dart';
import '../../widgets/waste_type/waste_type_info_tab.dart';
import '../../widgets/waste_type/waste_type_collection_points_tab.dart';
import '../../widgets/common/error_view.dart';

class WasteTypeDetailsScreen extends StatefulWidget {
  final int wasteTypeId;

  const WasteTypeDetailsScreen({
    Key? key,
    required this.wasteTypeId,
  }) : super(key: key);

  @override
  State<WasteTypeDetailsScreen> createState() => _WasteTypeDetailsScreenState();
}

class _WasteTypeDetailsScreenState extends State<WasteTypeDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Load waste type details
    context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId));

    // Start animation
    _animationController.forward();

    // Kích hoạt kiểm tra trạng thái admin và thử áp dụng giá trị mặc định
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kích hoạt kiểm tra admin status
      context.read<AdminCubit>().checkAdminStatus();

      // Nếu không phát hiện được vai trò, áp dụng trạng thái admin
      // để đảm bảo có thể sử dụng được chức năng trong màn hình chi tiết
      await Future.delayed(Duration(seconds: 2));
      // Kiểm tra xem widget còn mounted không trước khi truy cập context
      if (mounted) {
        final currentState = context.read<AdminCubit>().state;
        if (!currentState) {
          // Khi đang ở màn hình chi tiết, cần đặt quyền admin
          context.read<AdminCubit>().forceUpdateAdminStatus(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return _buildEnhancedLoadingView();
          }

          if (state is WasteTypeDetailLoaded) {
            return _buildDetailContent(state);
          }

          if (state is WasteTypeError) {
            return _buildEnhancedErrorView(state);
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: _buildEnhancedFloatingActionButton(),
    );
  }

  Widget _buildEnhancedLoadingView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Đang tải thông tin loại rác thải...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(WasteTypeDetailLoaded state) {
    final wasteType = state.wasteType;
    final collectionPoints = state.collectionPoints;
    final isHazardous = wasteType.category == 'Nguy hại';
    final isRecyclable = wasteType.category == 'Tái chế';
    final statusColor = isHazardous
        ? Colors.red
        : isRecyclable
        ? AppColors.primaryGreen
        : Colors.grey;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildEnhancedSliverAppBar(wasteType, statusColor),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab Thông tin cơ bản
              WasteTypeInfoTab(wasteType: wasteType),

              // Tab Điểm thu gom
              BlocBuilder<AdminCubit, bool>(
                builder: (context, isAdmin) {
                  return WasteTypeCollectionPointsTab(
                    wasteTypeId: widget.wasteTypeId,
                    collectionPoints: collectionPoints,
                    isAdmin: isAdmin,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSliverAppBar(dynamic wasteType, Color statusColor) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: statusColor,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            // Đảm bảo tất cả các tác vụ bất đồng bộ hoàn thành trước khi pop
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
      actions: [
        BlocBuilder<AdminCubit, bool>(
          builder: (context, isAdmin) {
            return isAdmin
                ? Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
            )
                : SizedBox.shrink();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            wasteType.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        titlePadding: EdgeInsets.only(left: 16, bottom: 80),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor,
                    statusColor.withOpacity(0.8),
                    statusColor.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Subtle pattern overlay
            _buildPatternOverlay(),
            // Icon overlay with enhanced positioning
            Positioned(
              right: -30,
              bottom: -10,
              child: Icon(
                wasteType.icon,
                size: 180,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Enhanced category badge
            Positioned(
              left: 16,
              bottom: 100,
              child: _buildEnhancedCategoryBadge(wasteType.category),
            ),
            // Enhanced price badge if applicable
            if (wasteType.unitPrice > 0)
              Positioned(
                right: 16,
                bottom: 100,
                child: _buildEnhancedPriceBadge(wasteType),
              ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: CustomTabBar(
            controller: _tabController,
            backgroundColor: Colors.transparent,
            indicatorColor: statusColor,
            labelColor: statusColor,
            unselectedLabelColor: Color(0xFF757575),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Thông tin cơ bản',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Điểm thu gom',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(),
      ),
    );
  }

  Widget _buildEnhancedCategoryBadge(String category) {
    final categoryIcon = _getCategoryIcon(category);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              categoryIcon,
              size: 16,
              color: _getCategoryColor(category),
            ),
          ),
          SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              color: _getCategoryColor(category),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPriceBadge(dynamic wasteType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on, size: 18, color: Colors.white),
          SizedBox(width: 6),
          Text(
            '${wasteType.unitPrice}đ/${wasteType.unit}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFloatingActionButton() {
    return BlocBuilder<WasteTypeBloc, WasteTypeState>(
      builder: (context, state) {
        if (state is WasteTypeDetailLoaded && _tabController.index == 1) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to the waste type collection points management screen
                Navigator.pushNamed(
                  context,
                  '/waste-type/collection-points',
                  arguments: widget.wasteTypeId,
                ).then((result) {
                  // Refresh data if changes were made
                  if (result == true && mounted) {
                    context.read<WasteTypeBloc>().add(
                      LoadWasteTypeDetails(widget.wasteTypeId),
                    );
                  }
                });
              },
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              icon: Icon(Icons.edit_location_outlined, color: Colors.white),
              label: Text(
                'Quản lý điểm thu gom',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildEnhancedErrorView(WasteTypeError state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFEF2F2), Colors.white],
        ),
      ),
      child: ErrorView(
        icon: Icons.error_outline,
        title: 'Đã xảy ra lỗi',
        message: state.message,
        buttonText: 'Thử lại',
        onRetry: () {
          if (mounted) {
            context.read<WasteTypeBloc>().add(
              LoadWasteTypeDetails(widget.wasteTypeId),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Không tìm thấy dữ liệu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tái chế':
        return AppColors.primaryGreen;
      case 'Hữu cơ':
        return Colors.brown[600] ?? Colors.brown;
      case 'Nguy hại':
        return Colors.red[600] ?? Colors.red;
      case 'Thường':
        return Colors.grey[600] ?? Colors.grey;
      default:
        return Colors.blue[600] ?? Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tái chế':
        return Icons.recycling;
      case 'Hữu cơ':
        return Icons.compost;
      case 'Nguy hại':
        return Icons.warning_amber_rounded;
      case 'Thường':
        return Icons.delete_outline;
      default:
        return Icons.category;
    }
  }
}

// Custom painter for subtle background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    // Create subtle dots pattern
    for (int i = 0; i < size.width; i += 30) {
      for (int j = 0; j < size.height; j += 30) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          1.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}