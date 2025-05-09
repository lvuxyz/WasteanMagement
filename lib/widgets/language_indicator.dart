import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_state.dart';
import '../generated/l10n.dart';

class LanguageIndicator extends StatelessWidget {
  final bool showLabel;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  
  const LanguageIndicator({
    Key? key,
    this.showLabel = true,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        if (state is LanguageLoaded) {
          final isEnglish = state.languageCode == 'en';
          final bgColor = backgroundColor ?? Theme.of(context).primaryColor.withOpacity(0.1);
          final txtColor = textColor ?? Theme.of(context).primaryColor;
          
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      image: DecorationImage(
                        image: AssetImage(
                          isEnglish ? 'assets/flags/gb.png' : 'assets/flags/vn.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 8),
                    Text(
                      isEnglish ? l10n.english : l10n.vietnamese,
                      style: TextStyle(
                        color: txtColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
} 