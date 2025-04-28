import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_type/waste_type_bloc.dart';
import '../blocs/waste_type/waste_type_event.dart';
import '../blocs/waste_type/waste_type_state.dart';
import '../utils/app_colors.dart';
import '../widgets/waste_type/waste_type_list_item.dart';
import '../widgets/common/search_field.dart';
import '../widgets/common/filter_dropdown.dart';
import '../widgets/common/confirmation_dialog.dart';
import '../generated/l10n.dart';

class WasteTypeListScreen extends StatefulWidget {
  const WasteTypeListScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeListScreen> createState() => _WasteTypeListScreenState();
}

class _WasteTypeListScreenState extends State<WasteTypeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  bool _isAdmin = true; // Thực tế cần lấy từ context hoặc user repository

  @override
  void initState() {
    super.initState();
    context.read<WasteTypeBloc>().add(LoadWasteTypes());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<WasteTypeBloc>().add(SearchWasteTypes(_searchController.text));
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      context.read<WasteTypeBloc>().add(FilterWasteTypesByCategory(category));
    }
  }

  void _showDeleteConfirmation(BuildContext context, int wasteTypeId, String name) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa loại rác',
        content: 'Bạn có chắc chắn muốn xóa loại rác "$name" không?',
        confirmText: 'Xóa',
        cancelText: 'Hủy',
        onConfirm: () {
          Navigator.of(context).pop();
          // Add delete event here when implemented
          context.read<WasteTypeBloc>().add(DeleteWasteType(wasteTypeId));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Quản lý Loại Rác Thải',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Nút refresh
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<WasteTypeBloc>().add(LoadWasteTypes());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  flex: 3,
                  child: SearchField(
                    controller: _searchController,
                    hintText: 'Tìm kiếm loại rác...',
                    onClear: () {
                      _searchController.clear();
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Category filter
                Expanded(
                  flex: 2,
                  child: FilterDropdown(
                    value: _selectedCategory,
                    items: const [
                      'Tất cả',
                      'Tái chế',
                      'Hữu cơ',
                      'Nguy hại',
                      'Thường',
                    ],
                    onChanged: _onCategoryChanged,
                  ),
                ),
              ],
            ),
          ),

          // List of waste types
          Expanded(
            child: BlocConsumer<WasteTypeBloc, WasteTypeState>(
              listener: (context, state) {
                if (state is WasteTypeDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa loại rác thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload list
                  context.read<WasteTypeBloc>().add(LoadWasteTypes());
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

                if (state is WasteTypeLoaded) {
                  final wasteTypes = state.filteredWasteTypes;

                  if (wasteTypes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
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
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: wasteTypes.length,
                    itemBuilder: (context, index) {
                      final wasteType = wasteTypes[index];
                      return WasteTypeListItem(
                        wasteType: wasteType,
                        onView: () {
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: wasteType.id,
                          );
                        },
                        onEdit: _isAdmin ? () {
                          Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: wasteType.id,
                          );
                        } : null,
                        onDelete: _isAdmin ? () {
                          _showDeleteConfirmation(
                            context,
                            wasteType.id,
                            wasteType.name,
                          );
                        } : null,
                        onManageCollectionPoints: _isAdmin ? () {
                          Navigator.pushNamed(
                            context,
                            '/collection-points',
                            arguments: wasteType.id,
                          );
                        } : null,
                      );
                    },
                  );
                }

                return Center(
                  child: Text('Đã xảy ra lỗi khi tải dữ liệu'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          Navigator.pushNamed(context, '/edit');
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }
}