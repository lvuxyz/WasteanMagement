import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/waste_guide/waste_guide_bloc.dart';
import '../blocs/waste_guide/waste_guide_event.dart';
import '../blocs/waste_guide/waste_guide_state.dart';
import '../utils/app_colors.dart';

class WasteClassificationGuideScreen extends StatefulWidget {
  const WasteClassificationGuideScreen({Key? key}) : super(key: key);

  @override
  State<WasteClassificationGuideScreen> createState() => _WasteClassificationGuideScreenState();
}

class _WasteClassificationGuideScreenState extends State<WasteClassificationGuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        case 0:
          category = 'Tất cả';
          break;
        case 1:
          category = 'Rác tái chế';
          break;
        case 2:
          category = 'Rác hữu cơ';
          break;
        case 3:
          category = 'Rác nguy hại';
          break;
      }
      context.read<WasteGuideBloc>().add(FilterWasteGuideByCategory(category));
    }
  }

  void _onSearchChanged() {
    context.read<WasteGuideBloc>().add(SearchWasteGuide(_searchController.text));
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
      create: (context) => WasteGuideBloc()..add(LoadWasteGuide()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primaryGreen,
              title: _isSearching
                  ? _buildSearchField()
                  : const Text(
                'Hướng dẫn Phân loại Rác',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
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
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Rác tái chế'),
                  Tab(text: 'Rác hữu cơ'),
                  Tab(text: 'Rác nguy hại'),
                ],
              ),
            ),
            body: BlocConsumer<WasteGuideBloc, WasteGuideState>(
              listener: (context, state) {
                if (state is WasteGuideError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is WasteGuideInitial || state is WasteGuideLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryGreen),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải hướng dẫn phân loại rác...',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is WasteGuideLoaded) {
                  return Column(
                    children: [
                      // Thanh tìm kiếm (chỉ hiển thị khi không ở trong AppBar)
                      if (!_isSearching)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm trong hướng dẫn...',
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

                      // Hiển thị kết quả lọc
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hiển thị ${state.filteredCategories.length} danh mục',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Danh sách hướng dẫn
                      Expanded(
                        child: _buildGuideContent(context, state),
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
                          context.read<WasteGuideBloc>().add(LoadWasteGuide());
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
          );
        },
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
        hintText: 'Tìm kiếm trong hướng dẫn...',
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

  // Widget hiển thị nội dung hướng dẫn
  Widget _buildGuideContent(BuildContext context, WasteGuideLoaded state) {
    if (state.filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nội dung phù hợp',
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.filteredCategories.length,
      itemBuilder: (context, index) {
        final category = state.filteredCategories[index];
        return _buildCategorySection(category);
      },
    );
  }

  // Widget hiển thị thông tin danh mục
  Widget _buildCategorySection(WasteGuideCategory category) {
    final IconData iconData = _getIconData(category.iconName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Header của danh mục
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getCategoryColor(category.id).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCategoryColor(category.id).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.id).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: _getCategoryColor(category.id),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(category.id),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách các mục trong danh mục
        ...category.items.map((item) => _buildWasteItemCard(item, category.id)).toList(),

        // Khoảng cách giữa các danh mục
        const SizedBox(height: 24),
      ],
    );
  }

  // Widget hiển thị thông tin mục
  Widget _buildWasteItemCard(WasteGuideItem item, String categoryId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(categoryId).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getItemIconData(item.id),
            color: _getCategoryColor(categoryId),
            size: 24,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          item.description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Danh sách ví dụ
                const Text(
                  'Ví dụ:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: item.examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              example,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Hướng dẫn xử lý
                const Text(
                  'Cách xử lý:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.instructions,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Phương thức lấy màu cho danh mục
  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'recyclable':
        return Colors.blue;
      case 'organic':
        return Colors.green;
      case 'hazardous':
        return Colors.red;
      case 'general':
        return Colors.grey;
      default:
        return AppColors.primaryGreen;
    }
  }

  // Phương thức lấy biểu tượng cho danh mục
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'recycling':
        return Icons.recycling;
      case 'compost':
        return Icons.compost;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'delete':
        return Icons.delete_outline;
      default:
        return Icons.category;
    }
  }

  // Phương thức lấy biểu tượng cho mục
  IconData _getItemIconData(String itemId) {
    switch (itemId) {
      case 'plastic':
        return Icons.local_drink_outlined;
      case 'paper':
        return Icons.description_outlined;
      case 'metal':
        return Icons.settings_outlined;
      case 'glass':
        return Icons.wine_bar_outlined;
      case 'food_waste':
        return Icons.restaurant_outlined;
      case 'garden_waste':
        return Icons.grass;
      case 'battery':
        return Icons.battery_alert_outlined;
      case 'electronic':
        return Icons.smartphone_outlined;
      case 'chemical':
        return Icons.invert_colors;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'mixed_waste':
        return Icons.bubble_chart_outlined;
      case 'difficult_materials':
        return Icons.format_paint_outlined;
      default:
        return Icons.info_outline;
    }
  }
}