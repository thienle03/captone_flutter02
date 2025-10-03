import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<String> items;

  const BulletList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return const Text("-", style: TextStyle(color: Colors.black54));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [const Text("• "), Expanded(child: Text(e))],
                  ),
                ),
              )
              .toList(),
    );
  }
}
