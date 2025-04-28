import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/waste_type/waste_type_list_item.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/common/filter_dropdown.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../generated/l10n.dart';

class WasteTypeListScreen extends StatefulWidget {
  const WasteTypeListScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeListScreen> createState() => _WasteTypeListScreenState();
}

class _WasteTypeListScreenState extends State<WasteTypeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  bool _isAdmin = true; // Thực tế cần lấy từ context hoặc user repository
  bool _showFilterOptions = false;

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
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                _showFilterOptions = !_showFilterOptions;
              });
            },
          ),
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
          // Search bar - Always visible
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchField(
              controller: _searchController,
              hintText: 'Tìm kiếm loại rác...',
              onClear: () {
                _searchController.clear();
              },
            ),
          ),
          
          // Expandable filter options
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _showFilterOptions ? 80 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilterDropdown(
                            value: _selectedCategory,
                            items: const [
                              'Tất cả',
                              'Tái chế',
                              'Hữu cơ',
                              'Nguy hại',
                              'Thường',
                            ],
                            label: 'Danh mục',
                            onChanged: _onCategoryChanged,
                          ),
                        ),
                        SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: Icon(Icons.refresh, size: 18),
                          label: Text('Đặt lại'),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'Tất cả';
                            });
                            context.read<WasteTypeBloc>().add(FilterWasteTypesByCategory('Tất cả'));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: BorderSide(color: AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Status indicator (applied filters)
          if (_selectedCategory != 'Tất cả' || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Bộ lọc đang áp dụng:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (_selectedCategory != 'Tất cả')
                    Chip(
                      label: Text(_selectedCategory),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'Tất cả';
                        });
                        context.read<WasteTypeBloc>().add(FilterWasteTypesByCategory('Tất cả'));
                      },
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      labelStyle: TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  SizedBox(width: 4),
                  if (_searchController.text.isNotEmpty)
                    Chip(
                      label: Text('Tìm kiếm: ${_searchController.text}'),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _searchController.clear();
                      },
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      labelStyle: TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
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
                          SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedCategory = 'Tất cả';
                              });
                              context.read<WasteTypeBloc>().add(LoadWasteTypes());
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Xóa bộ lọc'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
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
                            '/waste-type/details',
                            arguments: wasteType.id,
                          );
                        },
                        onEdit: _isAdmin ? () {
                          Navigator.pushNamed(
                            context,
                            '/waste-type/edit',
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
                            '/waste-type/collection-points',
                            arguments: wasteType.id,
                          );
                        } : null,
                      );
                    },
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
                      SizedBox(height: 16),
                      Text(
                        'Đã xảy ra lỗi khi tải dữ liệu',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<WasteTypeBloc>().add(LoadWasteTypes());
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () {
          Navigator.pushNamed(context, '/waste-type/edit');
        },
        icon: Icon(Icons.add),
        label: Text('Thêm loại rác thải'),
      ) : null,
    );
  }
}