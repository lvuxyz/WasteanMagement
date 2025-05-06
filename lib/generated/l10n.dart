// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }
  
  // Các phương thức cho các chuỗi đa ngôn ngữ
  String get appTitle => Intl.message('My Application', name: 'appTitle');
  String get appDescription => Intl.message('Waste Management and Recycling App', name: 'appDescription');
  String get languageScreenTitle => Intl.message('Select Language', name: 'languageScreenTitle');
  String get english => Intl.message('English', name: 'english');
  String get vietnamese => Intl.message('Vietnamese', name: 'vietnamese');
  String get save => Intl.message('Save', name: 'save');
  String get cancel => Intl.message('Cancel', name: 'cancel');
  String get languageChanged => Intl.message('Language changed successfully', name: 'languageChanged');
  String get searchLanguage => Intl.message('Search language', name: 'searchLanguage');
  String get continueButton => Intl.message('Continue', name: 'continueButton');
  String get confirm => Intl.message('Confirm', name: 'confirm');
  String get changeLanguageTitle => Intl.message('Change Language', name: 'changeLanguageTitle');
  String get changeLanguageContent => Intl.message('Do you want to change the language?', name: 'changeLanguageContent');
  String get languageChangeSuccess => Intl.message('Language changed successfully', name: 'languageChangeSuccess');
  String get languageChangeError => Intl.message('Failed to change language', name: 'languageChangeError');
  String get welcomeTitle => Intl.message('LVuRác', name: 'welcomeTitle');
  String get welcomeSubtitle => Intl.message('Explore the application', name: 'welcomeSubtitle');
  String get welcomeDescription => Intl.message('Now your account is in one place and always under control', name: 'welcomeDescription');
  String get login => Intl.message('Login', name: 'login');
  String get createAccount => Intl.message('Create Account', name: 'createAccount');
  String get noLanguagesFound => Intl.message('No languages found', name: 'noLanguagesFound');
  String get loginTitle => Intl.message('Login', name: 'loginTitle');
  String get forgotPassword => Intl.message('Forgot password?', name: 'forgotPassword');
  String loginSuccess(String username) => Intl.message('Login successful! Welcome, $username', name: 'loginSuccess', args: [username]);
  String get username => Intl.message('Username', name: 'username');
  String get password => Intl.message('Password', name: 'password');
  String get enterUsername => Intl.message('Enter your username', name: 'enterUsername');
  String get enterPassword => Intl.message('Enter your password', name: 'enterPassword');
  String get usernameRequired => Intl.message('Username is required', name: 'usernameRequired');
  String get passwordRequired => Intl.message('Password is required', name: 'passwordRequired');
  String get forgotPasswordTitle => Intl.message('Forgot Password', name: 'forgotPasswordTitle');
  String get forgotPasswordDescription => Intl.message('Enter your email address and we\'ll send you a link to reset your password', name: 'forgotPasswordDescription');
  String get email => Intl.message('Email', name: 'email');
  String get enterEmail => Intl.message('Enter your email address', name: 'enterEmail');
  String get emailRequired => Intl.message('Email is required', name: 'emailRequired');
  String get invalidEmail => Intl.message('Please enter a valid email address', name: 'invalidEmail');
  String get resetPassword => Intl.message('Reset Password', name: 'resetPassword');
  String get resetPasswordSuccess => Intl.message('Password reset link has been sent to your email', name: 'resetPasswordSuccess');
  String get resetPasswordError => Intl.message('Failed to send reset password link', name: 'resetPasswordError');
  String get backToLogin => Intl.message('Back to Login', name: 'backToLogin');
  String get registrationTitle => Intl.message('Create Account', name: 'registrationTitle');
  String get registrationDescription => Intl.message('Fill in your details to create a new account', name: 'registrationDescription');
  String get fullName => Intl.message('Full Name', name: 'fullName');
  String get enterFullName => Intl.message('Enter your full name', name: 'enterFullName');
  String get fullNameRequired => Intl.message('Full name is required', name: 'fullNameRequired');
  String get confirmPassword => Intl.message('Confirm Password', name: 'confirmPassword');
  String get enterConfirmPassword => Intl.message('Re-enter your password', name: 'enterConfirmPassword');
  String get confirmPasswordRequired => Intl.message('Please confirm your password', name: 'confirmPasswordRequired');
  String get passwordsDoNotMatch => Intl.message('Passwords do not match', name: 'passwordsDoNotMatch');
  String get phone => Intl.message('Phone', name: 'phone');
  String get enterPhone  => Intl.message('Enter your phone number', name: 'enterPhone');
  String get address => Intl.message('Address', name: 'address');
  String get enterAddress => Intl.message('Enter your address', name: 'enterAddress');
  String get register => Intl.message('Register', name: 'register');
  String get registrationSuccess => Intl.message('Account created successfully', name: 'registrationSuccess');
  String get registrationError => Intl.message('Failed to create account', name: 'registrationError');
  String get alreadyHaveAccount => Intl.message('Already have an account? Login', name: 'alreadyHaveAccount');
  String get dontHaveAccount => Intl.message('Don\'t have an account?', name: 'dontHaveAccount');
  String get signUp => Intl.message('Sign Up', name: 'signUp');
  String get profile => Intl.message('Profile', name: 'profile');
  String get logout => Intl.message('Logout', name: 'logout');
  String get chooseLanguageSubtitle => Intl.message('Choose your preferred language for the application', name: 'chooseLanguageSubtitle');
  String hello(String username) => Intl.message('Hello, $username!', name: 'hello', args: [username]);
  String get quickActions => Intl.message('Quick Actions', name: 'quickActions');
  String get scanWaste => Intl.message('Scan Waste', name: 'scanWaste');
  String get schedule => Intl.message('Schedule', name: 'schedule');
  String get earnPoints => Intl.message('Earn Points', name: 'earnPoints');
  String get recentActivities => Intl.message('Recent Activities', name: 'recentActivities');
  String get initializingCamera => Intl.message('Initializing camera...', name: 'initializingCamera');
  String get analyzingWaste => Intl.message('Analyzing waste...', name: 'analyzingWaste');
  String get initializing => Intl.message('Initializing...', name: 'initializing');
  String get aiWasteScanner => Intl.message('AI Waste Scanner', name: 'aiWasteScanner');
  String get errorOccurred => Intl.message('An error occurred', name: 'errorOccurred');
  String get goBack => Intl.message('Go Back', name: 'goBack');
  String get tryAgain => Intl.message('Try Again', name: 'tryAgain');
  String get detectionResults => Intl.message('Detection Results', name: 'detectionResults');
  String get saveResults => Intl.message('Save Results', name: 'saveResults');
  String get enterWeight => Intl.message('Enter Weight', name: 'enterWeight');
  String get wasteType => Intl.message('Waste Type:', name: 'wasteType');
  String get weight => Intl.message('Weight', name: 'weight');
  String get unit => Intl.message('Unit', name: 'unit');
  String get detectionSuccess => Intl.message('Detection successful!', name: 'detectionSuccess');
  String get totalWasteSorted => Intl.message('Total Waste Sorted', name: 'totalWasteSorted');
  String monthlyGoal(String amount, String unit) => Intl.message('Monthly Goal: $amount$unit', name: 'monthlyGoal', args: [amount, unit]);
  String remainingAmount(String amount) => Intl.message('${amount}kg remaining', name: 'remainingAmount', args: [amount]);
  String get rememberMe => Intl.message('Remember me', name: 'rememberMe');
  String get pleaseTryAgain => Intl.message('Please try again', name: 'pleaseTryAgain');
  String get enterValidNumber => Intl.message('Please enter a valid number', name: 'enterValidNumber');
  String get pleaseEnterWeight => Intl.message('Please enter weight', name: 'pleaseEnterWeight');
  String get cannotDetectWaste => Intl.message('Cannot detect waste', name: 'cannotDetectWaste');
  String get placeWasteInCenter => Intl.message('Place waste in the center of the frame', name: 'placeWasteInCenter');
  String get enoughLight => Intl.message('Ensure enough light to see the object clearly', name: 'enoughLight');
  String get objectNotObscured => Intl.message('Object should not be obscured', name: 'objectNotObscured');
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

