class Language {
  final String code;
  final String name;
  final String flagAsset;
  final bool isSelected;

  Language({
    required this.code,
    required this.name,
    required this.flagAsset,
    this.isSelected = false,
  });

  Language copyWith({
    String? code,
    String? name,
    String? flagAsset,
    bool? isSelected,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      flagAsset: flagAsset ?? this.flagAsset,
      isSelected: isSelected ?? this.isSelected,
    );
  }
} 

