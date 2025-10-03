import 'package:flutter/material.dart';

class JobTile extends StatelessWidget {
  final String image;
  final String title;
  final dynamic price;
  final dynamic rating;
  final VoidCallback onTap;

  const JobTile({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child:
                  image.isEmpty
                      ? Container(color: const Color(0xFFEFEFEF))
                      : Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text("${rating ?? '-'}"),
                      const Spacer(),
                      Text(
                        "\$${price ?? '-'}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
