import 'package:flutter/material.dart';

class CustomTabBar extends TabBar {
  CustomTabBar({
    Key? key,
    required TabController controller,
    List<Widget>? tabs,
    Color? backgroundColor,
    Color labelColor = Colors.white,
    Color unselectedLabelColor = Colors.white70,
    Color? indicatorColor,
    double indicatorWeight = 2.0,
  }) : super(
    key: key,
    controller: controller,
    tabs: tabs ?? [],
    labelColor: labelColor,
    unselectedLabelColor: unselectedLabelColor,
    indicatorColor: indicatorColor ?? labelColor,
    indicatorWeight: indicatorWeight,
    indicatorSize: TabBarIndicatorSize.tab,
  );
} 