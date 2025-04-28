import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../models/waste_type_model.dart';
import '../../utils/app_colors.dart';

class WasteTypeTestScreen extends StatefulWidget {
  const WasteTypeTestScreen({Key? key}) : super(key: key);

  @override
  State<WasteTypeTestScreen> createState() => _WasteTypeTestScreenState();
}

class _WasteTypeTestScreenState extends State<WasteTypeTestScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách loại rác khi màn hình được khởi tạo
    context.read<WasteTypeBloc>().add(LoadWasteTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra API Loại Rác'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: BlocConsumer<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is WasteTypeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            developer.log('Lỗi tải danh sách loại rác: ${state.message}', error: state.message);
          }
        },
        builder: (context, state) {
          if (state is WasteTypeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WasteTypeLoaded) {
            final wasteTypes = state.wasteTypes;
            
            if (wasteTypes.isEmpty) {
              return const Center(
                child: Text('Không có loại rác nào.'),
              );
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
                  Text('Lỗi: ${state.message}'),
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
          } else {
            return const Center(
              child: Text('Nhấn nút Tải lại để tải dữ liệu'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tải lại danh sách loại rác
          context.read<WasteTypeBloc>().add(LoadWasteTypes());
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildWasteTypeCard(BuildContext context, WasteType wasteType) {
    // Xác định biểu tượng và màu sắc dựa trên loại rác
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

                      Text(
                        wasteType.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${wasteType.unitPrice} VNĐ/${wasteType.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Recyclable Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: wasteType.recyclable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    wasteType.recyclable ? 'Có thể tái chế' : 'Không thể tái chế',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: wasteType.recyclable ? Colors.green : Colors.red,
                    ),
                  ),
                ),

                // Category Chip
                if (wasteType.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      wasteType.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 