import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/waste_type/waste_type_item.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/search_field.dart';

class CollectionPointWasteTypesScreen extends StatefulWidget {
  final int collectionPointId;
  final String collectionPointName;

  const CollectionPointWasteTypesScreen({
    Key? key,
    required this.collectionPointId,
    required this.collectionPointName,
  }) : super(key: key);

  @override
  State<CollectionPointWasteTypesScreen> createState() => _CollectionPointWasteTypesScreenState();
}

class _CollectionPointWasteTypesScreenState extends State<CollectionPointWasteTypesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Load waste types for this collection point
    context.read<WasteTypeBloc>().add(
      LoadWasteTypesForCollectionPoint(
        collectionPointId: widget.collectionPointId,
        collectionPointName: widget.collectionPointName,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Loại rác tại: ${widget.collectionPointName}',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<WasteTypeBloc>().add(
                LoadWasteTypesForCollectionPoint(
                  collectionPointId: widget.collectionPointId,
                  collectionPointName: widget.collectionPointName,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WasteTypeBloc, WasteTypeState>(
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return LoadingView(message: 'Đang tải loại rác...');
          }

          if (state is WasteTypesForCollectionPointLoaded) {
            final wasteTypes = state.wasteTypes;
            
            if (wasteTypes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Không có loại rác nào tại điểm thu gom này',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hiện chưa có loại rác nào được liên kết\nvới điểm thu gom này',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Filter waste types by search query
            final filteredWasteTypes = _searchQuery.isEmpty
                ? wasteTypes
                : wasteTypes.where((wasteType) => 
                    wasteType.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    wasteType.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

            return Column(
              children: [
                // Search box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Tìm kiếm loại rác...',
                    onClear: () {
                      _searchController.clear();
                    },
                  ),
                ),
                
                // Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredWasteTypes.length} loại rác',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // List of waste types
                Expanded(
                  child: filteredWasteTypes.isEmpty && _searchQuery.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'Không tìm thấy loại rác phù hợp',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredWasteTypes.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final wasteType = filteredWasteTypes[index];
                            return WasteTypeItem(
                              wasteType: wasteType,
                              onTap: () {
                                Navigator.pushNamed(
                                  context, 
                                  '/waste-type/details',
                                  arguments: wasteType.id,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
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
                  LoadWasteTypesForCollectionPoint(
                    collectionPointId: widget.collectionPointId,
                    collectionPointName: widget.collectionPointName,
                  ),
                );
              },
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