import 'package:equatable/equatable.dart';

abstract class HelpGuidanceState extends Equatable {
  const HelpGuidanceState();

  @override
  List<Object?> get props => [];
}

class HelpGuidanceInitial extends HelpGuidanceState {}

class HelpGuidanceLoaded extends HelpGuidanceState {
  final List<Map<String, dynamic>> faqItems;
  final List<Map<String, dynamic>> filteredFaqs;
  final List<Map<String, dynamic>> tutorialCategories;

  const HelpGuidanceLoaded({
    required this.faqItems,
    required this.filteredFaqs,
    required this.tutorialCategories,
  });

  @override
  List<Object?> get props => [faqItems, filteredFaqs, tutorialCategories];

  HelpGuidanceLoaded copyWith({
    List<Map<String, dynamic>>? faqItems,
    List<Map<String, dynamic>>? filteredFaqs,
    List<Map<String, dynamic>>? tutorialCategories,
  }) {
    return HelpGuidanceLoaded(
      faqItems: faqItems ?? this.faqItems,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
      tutorialCategories: tutorialCategories ?? this.tutorialCategories,
    );
  }
} 