import 'package:flutter/material.dart';

class TabHeader extends StatelessWidget {
  final VoidCallback? onTapInterests;
  const TabHeader({super.key, this.onTapInterests});

  @override
  Widget build(BuildContext context) {
    final selStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: const Color.fromARGB(255, 39, 129, 42));
    final norStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      child: Row(
        children: [
          Text("Categories", style: selStyle),
          const SizedBox(width: 16),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTapInterests,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 82, 191, 88),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text("Interests", style: norStyle),
            ),
          ),
        ],
      ),
    );
  }
}
