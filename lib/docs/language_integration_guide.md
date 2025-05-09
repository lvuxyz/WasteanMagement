# English-Vietnamese Language Integration Guide

This guide explains how to implement English-Vietnamese language support in your components for the waste management application.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Adding New Translations](#adding-new-translations)
3. [Using the LanguageService](#using-the-languageservice)
4. [Components with Language Support](#components-with-language-support)
5. [Best Practices](#best-practices)

## Basic Usage

To use localized text in your widget:

```dart
import 'package:flutter/material.dart';
import '../generated/l10n.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Text(l10n.myTranslatedText);
  }
}
```

## Adding New Translations

1. Add new strings to `lib/l10n/app_en.arb` (English)
2. Add the corresponding translations to `lib/l10n/app_vi.arb` (Vietnamese)
3. If using placeholders, define them properly in the ARB files:

```json
// app_en.arb
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}

// app_vi.arb
{
  "greeting": "Xin chào, {name}!"
}
```

## Using the LanguageService

The `LanguageService` provides utility methods for implementing language support:

```dart
import '../services/language_service.dart';

// Get current language code
String languageCode = LanguageService.getCurrentLanguageCode(context);

// Check if specific language is active
bool isEnglish = LanguageService.isCurrentLanguage(context, 'en');

// Change language with confirmation dialog
await LanguageService.showLanguageConfirmationDialog(
  context,
  'vi',
);

// Change language directly
await LanguageService.changeLanguage(context, 'vi');

// Add language support to any widget
LanguageService.withLanguageSupport(
  child: MyWidget(),
  listener: (context, state) {
    // Custom language change handler
  },
);

// Add a language selector
LanguageService.buildLanguageSelector(
  context: context,
  backgroundColor: Colors.grey[200],
  textColor: Colors.black,
);
```

## Components with Language Support

When creating new components, follow these steps:

1. Import the l10n file: `import '../generated/l10n.dart';`
2. Get the localization object: `final l10n = S.of(context);`
3. Use localized strings: `l10n.myTranslatedString`

For parameterized strings:

```dart
// For a string defined as "hello": "Hello, {name}!"
Text(l10n.hello(userName))
```

## Best Practices

1. **No Hardcoded Strings**: Always use the localization system for user-visible text.
2. **Keep Translations Organized**: Group related translations together in the ARB files.
3. **Use Descriptive Keys**: Make keys descriptive of their content.
4. **Comments for Translators**: Add context comments in ARB files if needed.
5. **Test Both Languages**: Regularly test your UI in both English and Vietnamese.
6. **Placeholder Usage**: Use placeholders for dynamic content, not string concatenation.
7. **Handle Long Text**: Ensure your UI can handle both short English and potentially longer Vietnamese translations.

## Troubleshooting

- If translations aren't showing up, ensure you've run the code generation step.
- If you get errors about missing translations, check that all keys exist in both ARB files.
- For placeholders, verify that the ARB files define the placeholder metadata properly.

For more details, refer to the `LanguageBloc`, `LanguageUtils`, and `LanguageService` implementations.
