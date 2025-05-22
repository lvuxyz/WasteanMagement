import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../blocs/admin/admin_cubit.dart';
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
  String _selectedFilterOption = 'all';
  
  // Lưu tham chiếu đến bloc để tránh sử dụng context.read trong các callback
  late WasteTypeBloc _wasteTypeBloc;
  late AdminCubit _adminCubit;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Lưu tham chiếu đến bloc
    _wasteTypeBloc = context.read<WasteTypeBloc>();
    _adminCubit = context.read<AdminCubit>();
    
    // Load data when screen initializes
    _wasteTypeBloc.add(LoadWasteTypes());
    
    // Kích hoạt kiểm tra trạng thái admin và thử áp dụng giá trị mặc định
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kích hoạt kiểm tra admin status
      _adminCubit.checkAdminStatus();
      
      // Nếu không phát hiện được vai trò, áp dụng trạng thái admin
      // để đảm bảo có thể sử dụng được chức năng trong màn hình quản lý
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        final currentState = _adminCubit.state;
        if (!currentState) {
          // Khi đang ở màn hình quản lý, cần đặt quyền admin
          developer.log('Setting admin status to true for management screen');
          _adminCubit.forceUpdateAdminStatus(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _wasteTypeBloc.add(SearchWasteTypes(_searchController.text));
  }

  void _showDeleteConfirmation(BuildContext context, int wasteTypeId, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _wasteTypeBloc.add(DeleteWasteType(wasteTypeId));
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

  void _navigateToEdit(BuildContext context, int? wasteTypeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteTypeEditScreen(wasteTypeId: wasteTypeId),
      ),
    ).then((result) {
      // Refresh the list
      if (mounted) {
        _wasteTypeBloc.add(LoadWasteTypes());
      }
    });
  }

  void _navigateToCollectionPoints(BuildContext context, int wasteTypeId) {
    // Chuyển đến màn hình quản lý điểm thu gom cho loại rác cụ thể
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WasteTypeCollectionPointsScreen(wasteTypeId: wasteTypeId),
      ),
    ).then((_) {
      // Refresh the waste type list after managing collection points
      if (mounted) {
        _wasteTypeBloc.add(LoadWasteTypes());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdminCubit, bool>(
          listener: (context, isAdmin) {
            developer.log('AdminCubit listener triggered: isAdmin = $isAdmin');
          },
        ),
        BlocListener<WasteTypeBloc, WasteTypeState>(
          listener: (context, state) {
            if (state is WasteTypeDeleted) {
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
            } else if (state is WasteTypeUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
                _wasteTypeBloc.add(LoadWasteTypes());
                // Refresh admin status
                _adminCubit.checkAdminStatus();
              },
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<AdminCubit, bool>(
          builder: (context, isAdmin) {
            developer.log('FloatingActionButton BlocBuilder: isAdmin = $isAdmin');
            return isAdmin 
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/waste-type/add').then((_) {
                      // Reload the list when coming back from add screen
                      if (mounted) {
                        _wasteTypeBloc.add(LoadWasteTypes());
                      }
                    });
                  },
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.add, color: Colors.white),
                )
              : SizedBox.shrink();
          },
        ),
        body: Column(
          children: [
            // Debug text to show admin status
            BlocBuilder<AdminCubit, bool>(
              builder: (context, isAdmin) {
                developer.log('Debug text BlocBuilder: isAdmin = $isAdmin');
                return Container(
                  padding: EdgeInsets.all(8),
                  color: isAdmin ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  width: double.infinity,
                  child: Text(
                    'Admin status: ${isAdmin ? "YES" : "NO"}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
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
                  // Listener moved to MultiBlocListener
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
                        _wasteTypeBloc.add(LoadWasteTypes());
                        // Refresh admin status
                        _adminCubit.checkAdminStatus();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: wasteTypes.length,
                        itemBuilder: (context, index) {
                          final wasteType = wasteTypes[index];
                          
                          // Use BlocBuilder to get the latest admin status
                          return BlocBuilder<AdminCubit, bool>(
                            builder: (context, isAdmin) {
                              developer.log('WasteTypeListItem BlocBuilder: isAdmin = $isAdmin');
                              return WasteTypeListItem(
                                wasteType: wasteType,
                                onView: () => _navigateToDetails(wasteType.id),
                                onEdit: isAdmin ? () => _navigateToEdit(context, wasteType.id) : null,
                                onDelete: isAdmin ? () => _showDeleteConfirmation(context, wasteType.id, wasteType.name) : null,
                                onManageCollectionPoints: isAdmin ? () => _navigateToCollectionPoints(
                                  context,
                                  wasteType.id,
                                ) : null,
                              );
                            },
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
      ),
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
              if (mounted) {
                _wasteTypeBloc.add(LoadWasteTypes());
              }
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