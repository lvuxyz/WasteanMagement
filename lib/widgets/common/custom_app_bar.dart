import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color iconColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 