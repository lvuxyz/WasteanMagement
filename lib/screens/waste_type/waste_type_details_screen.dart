import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_tab_bar.dart';
import '../../widgets/waste_type/waste_type_info_tab.dart';
import '../../widgets/waste_type/waste_type_collection_points_tab.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_view.dart';

class WasteTypeDetailsScreen extends StatefulWidget {
  final int wasteTypeId;

  const WasteTypeDetailsScreen({
    Key? key,
    required this.wasteTypeId,
  }) : super(key: key);

  @override
  State<WasteTypeDetailsScreen> createState() => _WasteTypeDetailsScreenState();
}

class _WasteTypeDetailsScreenState extends State<WasteTypeDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = true; // Thực tế cần lấy từ context hoặc user repository

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load waste type details
    context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return LoadingView(message: 'Đang tải thông tin loại rác thải...');
          }

          if (state is WasteTypeDetailLoaded) {
            final wasteType = state.wasteType;
            final collectionPoints = state.collectionPoints;
            final isHazardous = wasteType.category == 'Nguy hại';
            final isRecyclable = wasteType.category == 'Tái chế';
            final statusColor = isHazardous 
                ? Colors.red 
                : isRecyclable 
                    ? AppColors.primaryGreen 
                    : Colors.grey;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: statusColor,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      if (_isAdmin)
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/waste-type/edit',
                              arguments: widget.wasteTypeId,
                            ).then((value) {
                              // Reload details after edit
                              if (value == true) {
                                context.read<WasteTypeBloc>().add(
                                  LoadWasteTypeDetails(widget.wasteTypeId),
                                );
                              }
                            });
                          },
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        wasteType.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  statusColor,
                                  statusColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          // Icon overlay with some transparency
                          Positioned(
                            right: -50,
                            bottom: -20,
                            child: Icon(
                              wasteType.icon,
                              size: 200,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          // Category badge
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(wasteType.category),
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    wasteType.category,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Price badge if applicable
                          if (wasteType.unitPrice > 0)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${wasteType.unitPrice}đ/${wasteType.unit}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    bottom: CustomTabBar(
                      controller: _tabController,
                      backgroundColor: statusColor,
                      tabs: [
                        Tab(text: 'Thông tin cơ bản'),
                        Tab(text: 'Điểm thu gom'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Thông tin cơ bản
                  WasteTypeInfoTab(wasteType: wasteType),

                  // Tab Điểm thu gom
                  WasteTypeCollectionPointsTab(
                    wasteTypeId: widget.wasteTypeId,
                    collectionPoints: collectionPoints,
                    isAdmin: _isAdmin,
                  ),
                ],
              ),
            );
          }

          if (state is WasteTypeError) {
            return ErrorView(
              icon: Icons.error_outline,
              title: 'Đã xảy ra lỗi',
              message: state.message,
              buttonText: 'Thử lại',
              onRetry: () {
                context.read<WasteTypeBloc>().add(
                  LoadWasteTypeDetails(widget.wasteTypeId),
                );
              },
            );
          }

          return Center(
            child: Text('Không tìm thấy dữ liệu'),
          );
        },
      ),
      floatingActionButton: _isAdmin ? BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeDetailLoaded && _tabController.index == 1) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/waste-type/collection-points',
                  arguments: widget.wasteTypeId,
                ).then((value) {
                  if (value == true) {
                    context.read<WasteTypeBloc>().add(
                      LoadWasteTypeDetails(widget.wasteTypeId),
                    );
                  }
                });
              },
              backgroundColor: AppColors.primaryGreen,
              icon: Icon(Icons.add),
              label: Text('Quản lý điểm thu gom'),
            );
          }
          return SizedBox.shrink();
        },
      ) : null,
    );
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