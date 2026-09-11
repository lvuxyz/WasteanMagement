// widgets/common/custom_tab_bar.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    required String title,
    super.actions,
    bool super.centerTitle = true,
    Color backgroundColor = Colors.transparent,
    Color titleColor = Colors.white,
    super.automaticallyImplyLeading,
    double super.elevation = 0,
    super.bottom,
    super.leading,
  }) : super(
    title: Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: backgroundColor == Colors.transparent 
        ? AppColors.primaryGreen 
        : backgroundColor,
  );
}
