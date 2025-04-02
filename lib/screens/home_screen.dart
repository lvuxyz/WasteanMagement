import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Placeholder pages for different tabs
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      _buildCollectionPointsPage(),
      const Center(child: Text('Placeholder')), // This is for the center button
      _buildStatisticsPage(),
      _buildProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    // Skip the center button index (2) for normal navigation
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onCenterButtonPressed() {
    // Mở ra menu tùy chọn để chụp ảnh hoặc chọn ảnh từ thư viện
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhận diện rác bằng ảnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Chụp ảnh',
                  onTap: () {
                    Navigator.pop(context);
                    // Xử lý logic chụp ảnh ở đây
                    _showImageCaptureSuccess(context);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Chọn từ thư viện',
                  onTap: () {
                    Navigator.pop(context);
                    // Xử lý logic chọn ảnh từ thư viện ở đây
                    _showImageCaptureSuccess(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageCaptureSuccess(BuildContext context) {
    // Demo hiển thị kết quả nhận diện
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhận diện thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loại rác được nhận diện:'),
            const SizedBox(height: 10),
            _buildWasteTypeItem(
              icon: Icons.delete_outline,
              color: Colors.blue,
              name: 'Nhựa tái chế',
              confidence: '95%',
            ),
            const SizedBox(height: 8),
            _buildWasteTypeItem(
              icon: Icons.description_outlined,
              color: Colors.amber,
              name: 'Giấy, bìa carton',
              confidence: '5%',
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn có thể gửi rác tại các điểm thu gom gần nhất.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Chuyển đến trang gửi rác
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi rác ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypeItem({
    required IconData icon,
    required Color color,
    required String name,
    required String confidence,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          confidence,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 24),
            _buildUserSummaryCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Điểm thu gom gần bạn'),
            const SizedBox(height: 16),
            _buildCollectionPointsList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Loại rác được thu gom'),
            const SizedBox(height: 16),
            _buildWasteTypeList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Giao dịch gần đây'),
            const SizedBox(height: 16),
            _buildRecentTransactionsList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const Text(
              'Nguyễn Văn A', // Từ bảng Users.full_name
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryGreen,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Tổng điểm thưởng', // Từ bảng Rewards.points
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1,250', // Tổng Rewards.points của user
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '15.5 kg', // Tổng Transactions.quantity
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rác đã xử lý',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đổi điểm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionPointsList() {
    // Hiển thị từ bảng CollectionPoints
    List<Map<String, dynamic>> mockCollectionPoints = [
      {
        'id': 1,
        'name': 'Điểm thu gom Nguyễn Trãi',
        'address': 'Số 123 Nguyễn Trãi, Quận 1, TP.HCM',
        'distance': 2.5,
        'operating_hours': '08:00 - 17:00',
        'status': 'active',
        'capacity': 1000,
        'current_load': 450,
      },
      {
        'id': 2,
        'name': 'Điểm thu gom Lê Duẩn',
        'address': 'Số 456 Lê Duẩn, Quận 3, TP.HCM',
        'distance': 3.7,
        'operating_hours': '07:30 - 18:00',
        'status': 'active',
        'capacity': 800,
        'current_load': 650,
      },
      {
        'id': 3,
        'name': 'Điểm thu gom Nguyễn Đình Chiểu',
        'address': 'Số 789 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
        'distance': 4.2,
        'operating_hours': '08:00 - 17:30',
        'status': 'active',
        'capacity': 1200,
        'current_load': 300,
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mockCollectionPoints.length,
        itemBuilder: (context, index) {
          final point = mockCollectionPoints[index];
          final capacityPercentage = (point['current_load'] / point['capacity'] * 100).toInt();
          
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: capacityPercentage > 80 
                        ? Colors.red 
                        : capacityPercentage > 50 
                            ? Colors.orange 
                            : Colors.green,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              point['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$capacityPercentage%',
                              style: TextStyle(
                                color: capacityPercentage > 80 
                                    ? Colors.red 
                                    : AppColors.primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.textGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${point['distance']} km - ${point['address']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: point['status'] == 'active'
                                  ? AppColors.primaryGreen.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              point['status'] == 'active' ? 'Mở cửa' : 'Đóng cửa',
                              style: TextStyle(
                                color: point['status'] == 'active'
                                    ? AppColors.primaryGreen
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            point['operating_hours'],
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: point['current_load'] / point['capacity'],
                        backgroundColor: Colors.grey[200],
                        color: capacityPercentage > 80
                            ? Colors.red
                            : capacityPercentage > 50
                                ? Colors.orange
                                : AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Công suất: ${point['current_load']}/${point['capacity']} kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWasteTypeList() {
    // Hiển thị từ bảng WasteTypes
    List<Map<String, dynamic>> mockWasteTypes = [
      {
        'id': 1,
        'name': 'Nhựa tái chế',
        'description': 'Chai, lọ, hộp nhựa đã qua sử dụng',
        'recyclable': true,
        'unit_price': 5000,
        'icon': Icons.delete_outline,
        'color': Colors.blue,
      },
      {
        'id': 2,
        'name': 'Giấy, bìa carton',
        'description': 'Sách báo, hộp giấy, bìa carton',
        'recyclable': true,
        'unit_price': 3000,
        'icon': Icons.description_outlined,
        'color': Colors.amber,
      },
      {
        'id': 3,
        'name': 'Kim loại',
        'description': 'Vỏ lon, đồ kim loại cũ',
        'recyclable': true,
        'unit_price': 7000,
        'icon': Icons.settings_outlined,
        'color': Colors.grey,
      },
      {
        'id': 4,
        'name': 'Kính, thủy tinh',
        'description': 'Chai lọ thủy tinh, đồ thủy tinh vỡ',
        'recyclable': true,
        'unit_price': 2000,
        'icon': Icons.wine_bar_outlined,
        'color': Colors.lightBlue,
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mockWasteTypes.length,
        itemBuilder: (context, index) {
          final wasteType = mockWasteTypes[index];
          
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: wasteType['color'].withOpacity(0.2),
                  child: Icon(
                    wasteType['icon'],
                    color: wasteType['color'],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  wasteType['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${wasteType['unit_price']} đ/kg',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    // Hiển thị từ bảng Transactions
    List<Map<String, dynamic>> mockTransactions = [
      {
        'id': 1,
        'waste_type': 'Nhựa tái chế',
        'quantity': 2.5,
        'collection_point': 'Điểm thu gom Nguyễn Trãi',
        'date': 'Hôm nay, 10:30',
        'status': 'completed',
        'points': 125,
        'color': Colors.blue,
      },
      {
        'id': 2,
        'waste_type': 'Giấy, bìa carton',
        'quantity': 3.2,
        'collection_point': 'Điểm thu gom Lê Duẩn',
        'date': 'Hôm qua, 15:45',
        'status': 'completed',
        'points': 96,
        'color': Colors.amber,
      },
      {
        'id': 3,
        'waste_type': 'Kim loại',
        'quantity': 1.8,
        'collection_point': 'Điểm thu gom Nguyễn Trãi',
        'date': '22/05/2023, 09:15',
        'status': 'pending',
        'points': 0,
        'color': Colors.grey,
      },
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: mockTransactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = mockTransactions[index];
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.recycling,
              color: transaction['color'],
            ),
          ),
          title: Text(
            '${transaction['waste_type']} (${transaction['quantity']} kg)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction['collection_point'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                transaction['date'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: transaction['status'] == 'completed'
              ? Text(
                  '+${transaction['points']}',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Đang xử lý',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCollectionPointsPage() {
    return const Center(
      child: Text('Trang Điểm Thu Gom'),
    );
  }

  Widget _buildStatisticsPage() {
    return const Center(
      child: Text('Trang Thống Kê'),
    );
  }

  Widget _buildProfilePage() {
    return const Center(
      child: Text('Trang Cá Nhân'),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Regular navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.location_on_outlined, 1),
              // Empty space for the center button
              const SizedBox(width: 65),
              _buildNavItem(Icons.bar_chart_outlined, 3),
              _buildNavItem(Icons.person_outline, 4),
            ],
          ),
          // Center button
          Positioned(
            top: -15,
            child: _buildCenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      padding: const EdgeInsets.all(8),
      highlightColor: Colors.white24,
      splashColor: Colors.white24,
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: _onCenterButtonPressed,
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt,
          color: AppColors.primaryGreen,
          size: 30,
        ),
      ),
    );
  }
} 