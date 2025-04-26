import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_type/waste_type_bloc.dart';
import '../blocs/waste_type/waste_type_event.dart';
import '../blocs/waste_type/waste_type_state.dart';
import '../models/waste_type_model.dart';
import '../repositories/waste_type_repository.dart';
import '../utils/app_colors.dart';
import '../widgets/waste_type/waste_type_card.dart';
import '../widgets/waste_type/waste_type_detail.dart';
import '../widgets/waste_type/waste_type_guide.dart';
import '../widgets/common/custom_app_bar.dart'; // Sử dụng AppBar tùy chỉnh có sẵn

class WasteTypeManagementScreen extends StatefulWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeManagementScreen> createState() => _WasteTypeManagementScreenState();
}

class _WasteTypeManagementScreenState extends State<WasteTypeManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
      String category = 'Tất cả';
      switch (_tabController.index) {
        case 1:
          category = 'Tái chế';
          break;
        case 2:
          category = 'Nguy hại';
          break;
      }
      context.read<WasteTypeBloc>().add(FilterWasteTypesByCategory(category));
    }
  }

  void _onSearchChanged() {
    context.read<WasteTypeBloc>().add(SearchWasteTypes(_searchController.text));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteTypeBloc(
        repository: WasteTypeRepository(),
      )..add(LoadWasteTypes()),
      child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: AppColors.primaryGreen,
                title: _isSearching
                    ? _buildSearchField()
                    : const Text(
                  'Quản lý Loại Rác Thải',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  // Nút tìm kiếm
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _clearSearch();
                        }
                      });
                    },
                  ),
                  // Nút refresh
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      context.read<WasteTypeBloc>().add(LoadWasteTypes());
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Tái chế'),
                    Tab(text: 'Nguy hại'),
                  ],
                ),
              ),
              body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
                listener: (context, state) {
                  if (state is RecyclingPlanUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        action: SnackBarAction(
                          label: 'Thử lại',
                          textColor: Colors.white,
                          onPressed: () {
                            context.read<WasteTypeBloc>().add(LoadWasteTypes());
                          },
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Hiển thị loading khi đang tải dữ liệu
                  if (state is WasteTypeInitial || state is WasteTypeLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải dữ liệu...',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is WasteTypeLoaded) {
                    return Column(
                      children: [
                        // Thanh tìm kiếm (chỉ hiển thị khi không ở trong AppBar)
                        if (!_isSearching)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm loại rác...',
                                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.primaryGreen),
                                  onPressed: _clearSearch,
                                )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),

                        // Hiển thị số lượng kết quả
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tìm thấy ${state.filteredWasteTypes.length} loại rác',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  // Nút sắp xếp (có thể thêm chức năng sau)
                                  IconButton(
                                    icon: Icon(Icons.sort, color: Colors.grey[600]),
                                    onPressed: () {
                                      // Thêm chức năng sắp xếp sau này
                                    },
                                  ),
                                  // Nút lọc (có thể thêm chức năng sau)
                                  IconButton(
                                    icon: Icon(Icons.filter_list, color: Colors.grey[600]),
                                    onPressed: () {
                                      // Thêm chức năng lọc sau này
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Danh sách loại rác
                        Expanded(
                          child: _buildWasteTypesList(context, state.filteredWasteTypes),
                        ),
                      ],
                    );
                  }

                  // Xử lý trường hợp lỗi
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Đã xảy ra lỗi khi tải dữ liệu',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<WasteTypeBloc>().add(LoadWasteTypes());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Nút hướng dẫn phân loại rác
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: AppColors.primaryGreen,
                icon: const Icon(Icons.info_outline),
                label: const Text('Hướng dẫn phân loại'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const WasteTypeGuide(),
                  );
                },
              ),
            );
          }
      ),
    );
  }

  // Widget tìm kiếm trong AppBar
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm loại rác...',
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: _clearSearch,
        ),
      ),
    );
  }

  // Widget danh sách loại rác
  Widget _buildWasteTypesList(BuildContext context, List<WasteType> wasteTypes) {
    if (wasteTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy loại rác phù hợp',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
              label: const Text(
                'Xóa bộ lọc',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      );
    }

    // Hiển thị danh sách loại rác với animation
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<int>(wasteTypes.length),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: wasteTypes.length,
        itemBuilder: (context, index) {
          final wasteType = wasteTypes[index];
          return Hero(
            tag: 'waste_type_${wasteType.id}',
            child: Material(
              child: WasteTypeCard(
                wasteType: wasteType,
                onTap: () => _showWasteTypeDetail(context, wasteType),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hiển thị chi tiết loại rác
  void _showWasteTypeDetail(BuildContext context, WasteType wasteType) {
    context.read<WasteTypeBloc>().add(SelectWasteType(wasteType.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WasteTypeDetail(
        wasteType: wasteType,
      ),
    );
  }
}