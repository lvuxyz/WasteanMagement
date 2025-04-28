import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';
import 'waste_type_details_screen.dart';
import 'waste_type_edit_screen.dart';

class WasteTypeListScreen extends StatefulWidget {
  const WasteTypeListScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeListScreen> createState() => _WasteTypeListScreenState();
}

class _WasteTypeListScreenState extends State<WasteTypeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterOption = 'all';
  bool _isAdmin = true; // Thực tế cần lấy từ context hoặc user repository

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load waste types when screen initializes
    context.read<WasteTypeBloc>().add(LoadWasteTypes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<WasteTypeBloc>().add(SearchWasteTypes(_searchController.text));
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterOption = filter;
    });
  }

  void _navigateToDetails(BuildContext context, int wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteTypeDetailsScreen(wasteTypeId: wasteTypeId),
      ),
    ).then((_) {
      // Refresh list when returning from details
      context.read<WasteTypeBloc>().add(LoadWasteTypes());
    });
  }

  void _navigateToEdit(BuildContext context, int? wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteTypeEditScreen(wasteTypeId: wasteTypeId),
      ),
    ).then((_) {
      // Refresh list when returning from edit
      context.read<WasteTypeBloc>().add(LoadWasteTypes());
    });
  }

  void _showDeleteConfirmation(BuildContext context, int wasteTypeId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa loại rác'),
        content: Text('Bạn có chắc chắn muốn xóa loại rác "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WasteTypeBloc>().add(DeleteWasteType(wasteTypeId));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Quản lý loại rác thải',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _searchController.clear();
              context.read<WasteTypeBloc>().add(LoadWasteTypes());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm loại rác...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tất cả'),
                  const SizedBox(width: 8),
                  _buildFilterChip('recyclable', 'Có thể tái chế'),
                  const SizedBox(width: 8),
                  _buildFilterChip('non_recyclable', 'Không tái chế'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Waste type list
          Expanded(
            child: BlocConsumer<WasteTypeBloc, WasteTypeState>(
              listener: (context, state) {
                if (state is WasteTypeDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa loại rác thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload data after deletion
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
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WasteTypeLoaded) {
                  var wasteTypes = state.filteredWasteTypes;

                  // Apply additional filtering based on selected filter option
                  if (_filterOption == 'recyclable') {
                    wasteTypes = wasteTypes.where((type) => type.recyclable).toList();
                  } else if (_filterOption == 'non_recyclable') {
                    wasteTypes = wasteTypes.where((type) => !type.recyclable).toList();
                  }

                  if (wasteTypes.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WasteTypeBloc>().add(LoadWasteTypes());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: wasteTypes.length,
                      itemBuilder: (context, index) {
                        final wasteType = wasteTypes[index];
                        return _buildWasteTypeCard(context, wasteType);
                      },
                    ),
                  );
                } else if (state is WasteTypeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<WasteTypeBloc>().add(LoadWasteTypes());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('Không có dữ liệu'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton(
        onPressed: () => _navigateToEdit(context, null),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterOption == value;

    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWasteTypeCard(BuildContext context, WasteType wasteType) {
    // Determine icon and color based on recyclability
    final IconData typeIcon = wasteType.recyclable
        ? Icons.recycling
        : Icons.delete_outline;
    final Color typeColor = wasteType.recyclable
        ? Colors.green
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(context, wasteType.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wasteType.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Recyclable badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: wasteType.recyclable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            wasteType.recyclable ? 'Tái chế được' : 'Không tái chế',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: wasteType.recyclable ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          wasteType.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  if (_isAdmin)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEdit(context, wasteType.id);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(
                            context,
                            wasteType.id,
                            wasteType.name,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Price information if available
              if (wasteType.unitPrice > 0) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Giá thu mua: ${wasteType.unitPrice}đ/kg',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],

              // Handling instructions preview
              if (wasteType.handlingInstructions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        wasteType.handlingInstructions,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy loại rác phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _filterOption = 'all';
              });
              context.read<WasteTypeBloc>().add(LoadWasteTypes());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Đặt lại'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}