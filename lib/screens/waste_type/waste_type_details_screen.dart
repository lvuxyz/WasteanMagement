import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_type/waste_type_bloc.dart';
import '../blocs/waste_type/waste_type_event.dart';
import '../blocs/waste_type/waste_type_state.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_tab_bar.dart';
import '../widgets/waste_type/waste_type_info_tab.dart';
import '../widgets/waste_type/waste_type_collection_points_tab.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: BlocBuilder<WasteTypeBloc, WasteTypeState>(
          builder: (context, state) {
            if (state is WasteTypeDetailLoaded) {
              return Text(
                'Chi tiết: ${state.wasteType.name}',
                style: TextStyle(color: Colors.white),
              );
            }
            return Text(
              'Chi tiết loại rác',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit',
                  arguments: widget.wasteTypeId,
                );
              },
            ),
        ],
        bottom: CustomTabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Thông tin cơ bản'),
            Tab(text: 'Điểm thu gom'),
          ],
        ),
      ),
      body: BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is WasteTypeDetailLoaded) {
            final wasteType = state.wasteType;
            final collectionPoints = state.collectionPoints;

            return TabBarView(
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