import 'package:flutter/material.dart';
import '../widgets/category_group_card.dart';

class CategoryGroupDetailPage extends StatelessWidget {
  final String tenLoaiCongViec;
  final List<dynamic> dsNhomChiTietLoai;

  const CategoryGroupDetailPage({
    super.key,
    required this.tenLoaiCongViec,
    required this.dsNhomChiTietLoai,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tenLoaiCongViec)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: dsNhomChiTietLoai.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final nhom = (dsNhomChiTietLoai[i] ?? {}) as Map<String, dynamic>;
          return CategoryGroupCard(nhom: nhom);
        },
      ),
    );
  }
}
