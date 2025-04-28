import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_type/waste_type_bloc.dart';
import '../blocs/waste_type/waste_type_event.dart';
import '../blocs/waste_type/waste_type_state.dart';
import '../models/collection_point_model.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../widgets/collection_point/linked_collection_points_tab.dart';
import '../widgets/collection_point/add_collection_points_tab.dart';

class WasteTypeCollectionPointsScreen extends StatefulWidget {
  final int wasteTypeId;

  const WasteTypeCollectionPointsScreen({
    Key? key,
    required this.wasteTypeId,
  }) : super(key: key);

  @override
  State<WasteTypeCollectionPointsScreen> createState() => _WasteTypeCollectionPointsScreenState();
}

class _WasteTypeCollectionPointsScreenState extends State<WasteTypeCollectionPointsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load waste type details with collection points
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: BlocBuilder<WasteTypeBloc, WasteTypeState>(
          builder: (context, state) {
            if (state is WasteTypeDetailLoaded) {
              return Text(
                'Điểm thu gom: ${state.wasteType.name}',
                style: TextStyle(color: Colors.white),
              );
            }
            return Text(
              'Quản lý điểm thu gom',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        bottom: CustomTabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Đã liên kết'),
            Tab(text: 'Thêm điểm thu gom'),
          ],
        ),
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is CollectionPointLinked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm điểm thu gom thành công'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload to get updated list
            context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId));
          } else if (state is CollectionPointUnlinked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xóa liên kết điểm thu gom thành công'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload to get updated list
            context.read<WasteTypeBloc>().add(LoadWasteTypeDetails(widget.wasteTypeId));
          } else if (state is WasteTypeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is WasteTypeDetailLoaded) {
            final wasteType = state.wasteType;
            final linkedCollectionPoints = state.collectionPoints;
            final allCollectionPoints = state.allCollectionPoints ?? [];

            // Filter out already linked collection points
            final availableCollectionPoints = allCollectionPoints
                .where((cp) => !linkedCollectionPoints.any((lcp) => lcp.id == cp.id))
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab Điểm thu gom đã liên kết
                LinkedCollectionPointsTab(
                  wasteTypeId: widget.wasteTypeId,
                  collectionPoints: linkedCollectionPoints,
                  onUnlinkCollectionPoint: (collectionPointId) {
                    context.read<WasteTypeBloc>().add(
                      UnlinkCollectionPoint(
                        wasteTypeId: widget.wasteTypeId,
                        collectionPointId: collectionPointId,
                      ),
                    );
                  },
                ),

                // Tab Thêm điểm thu gom
                AddCollectionPointsTab(
                  wasteTypeId: widget.wasteTypeId,
                  availableCollectionPoints: availableCollectionPoints,
                  onLinkCollectionPoint: (collectionPointId) {
                    context.read<WasteTypeBloc>().add(
                      LinkCollectionPoint(
                        wasteTypeId: widget.wasteTypeId,
                        collectionPointId: collectionPointId,
                      ),
                    );
                  },
                ),
              ],
            );
          }

          if (state is WasteTypeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WasteTypeBloc>().add(
                        LoadWasteTypeDetails(widget.wasteTypeId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text('Không tìm thấy dữ liệu'),
          );
        },
      ),
    );
  }
}