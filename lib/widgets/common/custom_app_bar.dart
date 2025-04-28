// widgets/common/custom_tab_bar.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const CustomTabBar({
    Key? key,
    required this.controller,
    required this.tabs,
  }) : super(key: key);

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
    Key? key,
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    Color backgroundColor = Colors.transparent,
    Color titleColor = Colors.white,
    bool automaticallyImplyLeading = true,
    double elevation = 0,
    PreferredSizeWidget? bottom,
    Widget? leading,
  }) : super(
    key: key,
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
    centerTitle: centerTitle,
    elevation: elevation,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
    bottom: bottom,
    leading: leading,
  );
}
