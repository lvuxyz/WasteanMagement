// widgets/common/custom_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../generated/l10n.dart';
import '../../services/language_service.dart';

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
    bool showLanguageSelector = false,
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
    actions: [
      if (showLanguageSelector)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () {
              final currentLanguage = LanguageService.getCurrentLanguageCode(key!.currentContext!);
              final newLanguage = currentLanguage == 'en' ? 'vi' : 'en';
              
              LanguageService.showLanguageConfirmationDialog(
                key!.currentContext!,
                newLanguage,
              ).then((confirmed) {
                if (confirmed) {
                  LanguageService.changeLanguage(key!.currentContext!, newLanguage);
                }
              });
            },
          ),
        ),
      if (actions != null) ...actions,
    ],
    bottom: bottom,
    leading: leading,
  );
  
  static CustomAppBar localized({
    Key? key,
    required BuildContext context,
    required String Function(S) titleBuilder,
    List<Widget>? actions,
    bool centerTitle = true,
    Color backgroundColor = Colors.transparent,
    Color titleColor = Colors.white,
    bool automaticallyImplyLeading = true,
    double elevation = 0,
    PreferredSizeWidget? bottom,
    Widget? leading,
    bool showLanguageSelector = false,
  }) {
    final l10n = S.of(context);
    return CustomAppBar(
      key: key,
      title: titleBuilder(l10n),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      bottom: bottom,
      leading: leading,
      showLanguageSelector: showLanguageSelector,
    );
  }
}
