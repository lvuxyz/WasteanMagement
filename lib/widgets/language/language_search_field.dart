import 'package:flutter/material.dart';

class LanguageSearchField extends StatelessWidget {
  const LanguageSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
        onChanged: (value) {
          // In a real app, this would filter the language list
          // based on the search query
        },
      ),
    );
  }
} 