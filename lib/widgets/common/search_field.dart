// widgets/common/search_field.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function()? onClear;
  final String? value;
  final Function(String)? onChanged;

  const SearchField({
    Key? key,
    required this.hintText,
    this.controller,
    this.onClear,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          suffixIcon: (controller != null && controller!.text.isNotEmpty) || 
                     (value != null && value!.isNotEmpty)
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
