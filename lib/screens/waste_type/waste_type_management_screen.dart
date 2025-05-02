import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../repositories/waste_type_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/waste_type/waste_type_list_item.dart';
import '../../utils/app_colors.dart';
import 'waste_type_details_screen.dart';
import 'waste_type_edit_screen.dart';
import 'waste_type_collection_points_screen.dart';
import 'dart:developer' as developer;

class WasteTypeManagementScreen extends StatefulWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeManagementScreen> createState() => _WasteTypeManagementScreenState();
}

class _WasteTypeManagementScreenState extends State<WasteTypeManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAdmin = false; // Default to false until we check user role
  String _selectedFilterOption = 'all';
  Map<int, bool> _deletingItems = {}; // Track which items are being deleted

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _checkAdminPrivileges();
  }

  Future<void> _checkAdminPrivileges() async {
    try {
      final userRepository = RepositoryProvider.of<UserRepository>(context);
      final user = await userRepository.getUserProfile();
      
      setState(() {
        _isAdmin = user.isAdmin;
      });
      
      developer.log('User admin status: $_isAdmin');
    } catch (e) {
      developer.log('Error checking admin privileges: $e', error: e);
      // Default to non-admin in case of error
      setState(() {
        _isAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<WasteTypeBloc>().add(SearchWasteTypes(_searchController.text));
  }

  void _showDeleteConfirmation(BuildContext blocContext, int wasteTypeId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa loại rác'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn xóa loại rác sau đây không?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Hành động này không thể hoàn tác và sẽ xóa vĩnh viễn dữ liệu này.',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _deletingItems[wasteTypeId] = true;
              });
              blocContext.read<WasteTypeBloc>().add(DeleteWasteType(wasteTypeId));
            },
            icon: Icon(Icons.delete_outline, size: 18),
            label: Text('Xác nhận xóa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(int wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteTypeDetailsScreen(wasteTypeId: wasteTypeId),
      ),
    );
  }

  void _navigateToEdit(BuildContext blocContext, int? wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<WasteTypeBloc>(blocContext),
          child: WasteTypeEditScreen(wasteTypeId: wasteTypeId),
        ),
      ),
    ).then((_) => context.read<WasteTypeBloc>().add(LoadWasteTypes()));
  }

  void _navigateToCollectionPoints(BuildContext blocContext, int wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<WasteTypeBloc>(blocContext),
          child: WasteTypeCollectionPointsScreen(wasteTypeId: wasteTypeId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ApiClient được khởi tạo từ RepositoryProvider
    final wasteTypeRepository = RepositoryProvider.of<WasteTypeRepository>(context);
    
    return BlocProvider(
      create: (context) => WasteTypeBloc(
        repository: wasteTypeRepository,
      )..add(LoadWasteTypes()),
      child: Builder(builder: (blocContext) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            title: Text(
              'Quản lý loại rác thải',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  _searchController.clear();
                  blocContext.read<WasteTypeBloc>().add(LoadWasteTypes());
                },
              ),
            ],
          ),
          floatingActionButton: _isAdmin 
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/waste-type/add').then((_) {
                    // Reload the list when coming back from add screen
                    blocContext.read<WasteTypeBloc>().add(LoadWasteTypes());
                  });
                },
                backgroundColor: AppColors.primaryGreen,
                child: Icon(Icons.add, color: Colors.white),
              )
            : null,
          body: Column(
            children: [
              // Search and filter bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm loại rác...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    
                    // Filter options
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'Tất cả'),
                            _buildFilterChip('recyclable', 'Có thể tái chế'),
                            _buildFilterChip('non_recyclable', 'Không tái chế'),
                          ],
                        ),
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
                      setState(() {
                        _deletingItems.remove(state.wasteTypeId);
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa loại rác thành công'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'Đóng',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    } else if (state is WasteTypeError) {
                      // Clear any deletion status on error
                      setState(() {
                        _deletingItems.clear();
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'Đóng',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is WasteTypeLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state is WasteTypeLoaded) {
                      var wasteTypes = state.filteredWasteTypes;
                      
                      // Apply additional filter based on selected option
                      if (_selectedFilterOption == 'recyclable') {
                        wasteTypes = wasteTypes.where((type) => type.recyclable).toList();
                      } else if (_selectedFilterOption == 'non_recyclable') {
                        wasteTypes = wasteTypes.where((type) => !type.recyclable).toList();
                      }

                      if (wasteTypes.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          blocContext.read<WasteTypeBloc>().add(LoadWasteTypes());
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: wasteTypes.length,
                          itemBuilder: (context, index) {
                            final wasteType = wasteTypes[index];
                            return WasteTypeListItem(
                              wasteType: wasteType,
                              onView: () => _navigateToDetails(wasteType.id),
                              onEdit: _isAdmin ? () => _navigateToEdit(blocContext, wasteType.id) : null,
                              onDelete: _isAdmin && !(_deletingItems[wasteType.id] ?? false) ? 
                                () => _showDeleteConfirmation(blocContext, wasteType.id, wasteType.name) : null,
                              onManageCollectionPoints: _isAdmin ? () => _navigateToCollectionPoints(
                                blocContext,
                                wasteType.id,
                              ) : null,
                              isDeleting: _deletingItems[wasteType.id] ?? false,
                            );
                          },
                        ),
                      );
                    }

                    return Center(child: Text('Không thể tải dữ liệu.'));
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilterOption == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterOption = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                _selectedFilterOption = 'all';
              });
              context.read<WasteTypeBloc>().add(LoadWasteTypes());
            },
            icon: Icon(Icons.refresh),
            label: Text('Đặt lại'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}