import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../routes.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'map_screen.dart';
import 'recycling_progress_screen.dart';
import 'reward/reward_screen.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({Key? key, this.username = ''}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _bubbleScale = 1.0;
  bool _isGlowing = false;
  Timer? _glowTimer;
  
  // Tooltip và badge
  bool _showTooltip = false;
  bool _showBadge = true;
  
  @override
  void initState() {
    super.initState();
    
    // Khởi tạo animation controller cho hiệu ứng pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Thiết lập animation scale từ 1.0 đến 1.1 và lặp lại
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseController.repeat(reverse: true);
    
    // Tạo hiệu ứng glow
    _startGlowTimer();
    
    // Kiểm tra xem có hiển thị tooltip không
    _checkTooltipVisibility();
  }
  
  Future<void> _checkTooltipVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTooltip = prefs.getBool('has_seen_chat_tooltip') ?? false;
    
    if (!hasSeenTooltip) {
      setState(() {
        _showTooltip = true;
      });
      
      // Hiển thị tooltip trong 5 giây
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showTooltip = false;
          });
          // Lưu trạng thái đã thấy tooltip
          prefs.setBool('has_seen_chat_tooltip', true);
        }
      });
    }
  }
  
  void _startGlowTimer() {
    _glowTimer?.cancel();
    _glowTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _isGlowing = true;
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isGlowing = false;
          });
        }
      });
    });
  }
  
  void _dismissBadge() {
    setState(() {
      _showBadge = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _glowTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
    // Hiển thị kết quả nhận diện
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
      appBar: _currentIndex != 0 ? null : AppBar(
        title: const Text('LVuRác'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          const HomeScreen(), // Trang chủ
          // Trang Địa điểm
          const MapScreen(),
          // Trang Thống kê
          const RecyclingProgressScreen(),
          // Trang Điểm thưởng - Truyền tham số isInTabView = true
          const RewardScreen(isInTabView: true),
          // Trang Cá nhân
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildChatBubble(),
          if (_showTooltip)
            Positioned(
              bottom: 70,
              right: 0,
              child: Container(
                constraints: BoxConstraints(maxWidth: 200),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hỏi trợ lý AI về quản lý chất thải',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nhấn để trò chuyện',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stars_outlined),
            activeIcon: Icon(Icons.stars),
            label: 'Điểm thưởng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatBubble() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bubbleScale * (_pulseController.value < 0.5 ? _pulseAnimation.value : 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.7),
                      AppColors.primaryGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(_isGlowing ? 0.7 : 0.3),
                      blurRadius: _isGlowing ? 18 : 12,
                      spreadRadius: _isGlowing ? 3 : 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      _animateBubble();
                      _dismissBadge();
                      Navigator.pushNamed(context, AppRoutes.chat);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Hiệu ứng xoay icon
                        Transform.rotate(
                          angle: _isGlowing ? 0.1 : 0,
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        // Hiệu ứng bong bóng nhỏ
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 15,
                          child: Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge thông báo
              if (_showBadge)
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _animateBubble() {
    setState(() {
      _bubbleScale = 0.85;
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _bubbleScale = 1.0;
        });
      }
    });
  }
}