import 'package:flutter/material.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FilterPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap?.call(),
    );
  }
}
