// widgets/common/search_field.dart
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function()? onClear;
  final String? value;
  final Function(String)? onChanged;
  final FocusNode? focusNode; // Allow passing an external focusNode

  const SearchField({
    Key? key,
    required this.hintText,
    this.controller,
    this.onClear,
    this.value,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  FocusNode? _focusNode;
  bool _isInternalFocusNode = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Only create a new FocusNode if one wasn't provided
    if (widget.focusNode == null) {
      _isInternalFocusNode = true;
      _focusNode = FocusNode();
    } else {
      _focusNode = widget.focusNode;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Only dispose the FocusNode if we created it internally
    if (_isInternalFocusNode && _focusNode != null) {
      _focusNode!.dispose();
    }
    _focusNode = null;
    super.dispose();
  }

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
        controller: widget.controller,
        // Check if _focusNode is valid before using it
        focusNode: _isDisposed ? null : _focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
          ),
          suffixIcon: (widget.controller != null && widget.controller!.text.isNotEmpty) || 
                     (widget.value != null && widget.value!.isNotEmpty)
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: widget.onClear,
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
