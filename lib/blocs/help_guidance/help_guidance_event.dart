import 'package:equatable/equatable.dart';

abstract class HelpGuidanceEvent extends Equatable {
  const HelpGuidanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadHelpGuidanceData extends HelpGuidanceEvent {}

class SearchFaqs extends HelpGuidanceEvent {
  final String query;

  const SearchFaqs(this.query);

  @override
  List<Object?> get props => [query];
} 