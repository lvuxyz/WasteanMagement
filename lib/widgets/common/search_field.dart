
// widgets/common/search_field.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onClear;

  const SearchField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: AppColors.primaryGreen),
          onPressed: onClear,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
