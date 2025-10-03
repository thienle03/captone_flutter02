import 'package:flutter/material.dart';
import 'package:fiverr/features/search/presentation/screens/search_page.dart';

class CategoryGroupCard extends StatelessWidget {
  final Map<String, dynamic> nhom;

  const CategoryGroupCard({super.key, required this.nhom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (nhom["tenNhom"] ?? "").toString();
    final img = (nhom["hinhAnh"] ?? "").toString();
    final dsCT = (nhom["dsChiTietLoai"] ?? []) as List<dynamic>;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (title.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(initialKeyword: title),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: img.isEmpty
                  ? Container(
                      color: const Color(0xFFEFEFEF),
                      child: const Icon(Icons.image_not_supported),
                    )
                  : Image.network(img, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (dsCT.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dsCT.map((ct) {
                        final name = (ct?["tenChiTiet"] ?? "").toString();
                        if (name.isEmpty) return const SizedBox();
                        return ActionChip(
                          label: Text(name),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SearchPage(initialKeyword: name),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  else
                    const Text(
                      "No subcategories",
                      style: TextStyle(color: Colors.black54),
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
