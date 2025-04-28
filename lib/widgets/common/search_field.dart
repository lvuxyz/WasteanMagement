// widgets/common/search_field.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SearchField extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onClear;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchField({
    Key? key,
    this.hintText = 'Tìm kiếm...',
    this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateClearButtonVisibility);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateClearButtonVisibility() {
    final hasFocus = _controller.text.isNotEmpty;
    if (hasFocus != _showClearButton) {
      setState(() {
        _showClearButton = hasFocus;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    } else if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 20,
          ),
          suffixIcon: _showClearButton
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                )
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.primaryGreen,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
