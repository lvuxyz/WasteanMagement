import 'package:flutter/material.dart';

class CustomTabBar extends TabBar {
  CustomTabBar({
    super.key,
    required TabController super.controller,
    List<Widget>? tabs,
    Color? backgroundColor,
    Color super.labelColor = Colors.white,
    Color super.unselectedLabelColor = Colors.white70,
    Color? indicatorColor,
    super.indicatorWeight,
  }) : super(
    tabs: tabs ?? [],
    indicatorColor: indicatorColor ?? labelColor,
    indicatorSize: TabBarIndicatorSize.tab,
  );
} 