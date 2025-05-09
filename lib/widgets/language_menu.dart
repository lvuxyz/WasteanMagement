import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../services/language_service.dart';

class LanguageMenu extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  
  const LanguageMenu({
    Key? key,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final isEnglish = state.languageCode == 'en';
          
          return PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: backgroundColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEnglish ? 'EN' : 'VI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
            onSelected: (String languageCode) {
              if (languageCode != state.languageCode) {
                LanguageService.changeLanguage(context, languageCode);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'en',
                child: _buildLanguageOption(
                  context,
                  'English',
                  'en',
                  state.languageCode,
                  'assets/flags/gb.png',
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'vi',
                child: _buildLanguageOption(
                  context,
                  'Tiếng Việt',
                  'vi',
                  state.languageCode,
                  'assets/flags/vn.png',
                ),
              ),
            ],
          );
        }
        
        return IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          onPressed: () {},
        );
      },
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String languageCode,
    String currentLanguage,
    String flagAsset,
  ) {
    final isSelected = languageCode == currentLanguage;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                image: DecorationImage(
                  image: AssetImage(flagAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ],
        ),
        if (isSelected)
          Icon(
            Icons.check,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
      ],
    );
  }
} 