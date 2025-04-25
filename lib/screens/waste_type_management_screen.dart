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

class WasteTypeManagementScreen extends StatefulWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeManagementScreen> createState() => _WasteTypeManagementScreenState();
}

class _WasteTypeManagementScreenState extends State<WasteTypeManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

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
                title: const Text(
                  'Quản lý Loại Rác Thải',
                  style: TextStyle(color: Colors.white),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
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
                      ),
                    );
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
                  if (state is WasteTypeInitial || state is WasteTypeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is WasteTypeLoaded) {
                    return Column(
                      children: [
                        // Thanh tìm kiếm
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm loại rác...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                        ),

                        // Danh sách loại rác
                        Expanded(
                          child: _buildWasteTypesList(context, state.filteredWasteTypes),
                        ),
                      ],
                    );
                  }

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
                        ElevatedButton(
                          onPressed: () {
                            context.read<WasteTypeBloc>().add(LoadWasteTypes());
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primaryGreen,
                child: const Icon(Icons.category_outlined),
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
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: wasteTypes.length,
      itemBuilder: (context, index) {
        final wasteType = wasteTypes[index];
        return WasteTypeCard(
          wasteType: wasteType,
          onTap: () => _showWasteTypeDetail(context, wasteType),
        );
      },
    );
  }

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