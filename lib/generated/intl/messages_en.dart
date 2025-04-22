// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(username) => "Hello, ${username}!";
  static String m1(username) => "Login successful! Welcome, ${username}";
  static String m2(amount, unit) => "Monthly Goal: ${amount}${unit}";
  static String m3(amount) => "${amount}kg remaining";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aiWasteScanner": MessageLookupByLibrary.simpleMessage("AI Waste Scanner"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage("Already have an account? Login"),
    "analyzingWaste": MessageLookupByLibrary.simpleMessage("Analyzing waste..."),
    "appDescription": MessageLookupByLibrary.simpleMessage("Waste Management and Recycling App"),
    "appTitle": MessageLookupByLibrary.simpleMessage("My Application"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannotDetectWaste": MessageLookupByLibrary.simpleMessage("Cannot detect waste"),
    "changeLanguageContent": MessageLookupByLibrary.simpleMessage("Do you want to change the language?"),
    "changeLanguageTitle": MessageLookupByLibrary.simpleMessage("Change Language"),
    "chooseLanguageSubtitle": MessageLookupByLibrary.simpleMessage("Choose your preferred language for the application"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmPasswordRequired": MessageLookupByLibrary.simpleMessage("Please confirm your password"),
    "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
    "detectionResults": MessageLookupByLibrary.simpleMessage("Detection Results"),
    "detectionSuccess": MessageLookupByLibrary.simpleMessage("Detection successful!"),
    "dontHaveAccount": MessageLookupByLibrary.simpleMessage("Don\'t have an account?"),
    "earnPoints": MessageLookupByLibrary.simpleMessage("Earn Points"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailRequired": MessageLookupByLibrary.simpleMessage("Email is required"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enoughLight": MessageLookupByLibrary.simpleMessage("Ensure enough light to see the object clearly"),
    "enterConfirmPassword": MessageLookupByLibrary.simpleMessage("Re-enter your password"),
    "enterEmail": MessageLookupByLibrary.simpleMessage("Enter your email address"),
    "enterFullName": MessageLookupByLibrary.simpleMessage("Enter your full name"),
    "enterPassword": MessageLookupByLibrary.simpleMessage("Enter your password"),
    "enterUsername": MessageLookupByLibrary.simpleMessage("Enter your username"),
    "enterValidNumber": MessageLookupByLibrary.simpleMessage("Please enter a valid number"),
    "enterWeight": MessageLookupByLibrary.simpleMessage("Enter Weight"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("An error occurred"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgotPasswordDescription": MessageLookupByLibrary.simpleMessage("Enter your email address and we\'ll send you a link to reset your password"),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage("Forgot Password"),
    "fullName": MessageLookupByLibrary.simpleMessage("Full Name"),
    "fullNameRequired": MessageLookupByLibrary.simpleMessage("Full name is required"),
    "goBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "hello": m0,
    "initializing": MessageLookupByLibrary.simpleMessage("Initializing..."),
    "initializingCamera": MessageLookupByLibrary.simpleMessage("Initializing camera..."),
    "invalidEmail": MessageLookupByLibrary.simpleMessage("Please enter a valid email address"),
    "languageChangeError": MessageLookupByLibrary.simpleMessage("Failed to change language"),
    "languageChangeSuccess": MessageLookupByLibrary.simpleMessage("Language changed successfully"),
    "languageChanged": MessageLookupByLibrary.simpleMessage("Language changed successfully"),
    "languageScreenTitle": MessageLookupByLibrary.simpleMessage("Select Language"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginSuccess": m1,
    "loginTitle": MessageLookupByLibrary.simpleMessage("Login"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "monthlyGoal": m2,
    "noLanguagesFound": MessageLookupByLibrary.simpleMessage("No languages found"),
    "objectNotObscured": MessageLookupByLibrary.simpleMessage("Object should not be obscured"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage("Password is required"),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage("Passwords do not match"),
    "placeWasteInCenter": MessageLookupByLibrary.simpleMessage("Place waste in the center of the frame"),
    "pleaseEnterWeight": MessageLookupByLibrary.simpleMessage("Please enter weight"),
    "pleaseTryAgain": MessageLookupByLibrary.simpleMessage("Please try again"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick Actions"),
    "recentActivities": MessageLookupByLibrary.simpleMessage("Recent Activities"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registrationDescription": MessageLookupByLibrary.simpleMessage("Fill in your details to create a new account"),
    "registrationError": MessageLookupByLibrary.simpleMessage("Failed to create account"),
    "registrationSuccess": MessageLookupByLibrary.simpleMessage("Account created successfully"),
    "registrationTitle": MessageLookupByLibrary.simpleMessage("Create Account"),
    "remainingAmount": m3,
    "rememberMe": MessageLookupByLibrary.simpleMessage("Remember me"),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "resetPasswordError": MessageLookupByLibrary.simpleMessage("Failed to send reset password link"),
    "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage("Password reset link has been sent to your email"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveResults": MessageLookupByLibrary.simpleMessage("Save Results"),
    "scanWaste": MessageLookupByLibrary.simpleMessage("Scan Waste"),
    "schedule": MessageLookupByLibrary.simpleMessage("Schedule"),
    "searchLanguage": MessageLookupByLibrary.simpleMessage("Search language"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "totalWasteSorted": MessageLookupByLibrary.simpleMessage("Total Waste Sorted"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "unit": MessageLookupByLibrary.simpleMessage("Unit"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameRequired": MessageLookupByLibrary.simpleMessage("Username is required"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Vietnamese"),
    "wasteType": MessageLookupByLibrary.simpleMessage("Waste Type:"),
    "weight": MessageLookupByLibrary.simpleMessage("Weight"),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage("Now your account is in one place and always under control"),
    "welcomeSubtitle": MessageLookupByLibrary.simpleMessage("Explore the application"),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage("LVuRác")
  };
}

