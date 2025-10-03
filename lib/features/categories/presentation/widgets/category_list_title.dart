import 'package:flutter/material.dart';
import '../screens/category_group_detail_page.dart';

class CategoryListTile extends StatelessWidget {
  final Map<String, dynamic> loai;
  final int index;

  const CategoryListTile({super.key, required this.loai, required this.index});

  @override
  Widget build(BuildContext context) {
    final title = (loai["tenLoaiCongViec"] ?? "").toString();
    final dsNhom = (loai["dsNhomChiTietLoai"] ?? []) as List<dynamic>;
    final preview = _previewSubTitles(dsNhom);

    return ListTile(
      leading: _leadingIcon(index),
      title: Text(
        title.isEmpty ? "Unnamed" : title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CategoryGroupDetailPage(
                  tenLoaiCongViec: title,
                  dsNhomChiTietLoai: dsNhom,
                ),
          ),
        );
      },
    );
  }

  // ghép 2–3 tên nhóm/chi tiết làm mô tả
  String _previewSubTitles(List<dynamic> dsNhom) {
    final tags = <String>[];
    for (final nhom in dsNhom.take(2)) {
      final tenNhom = (nhom?["tenNhom"] ?? "").toString();
      if (tenNhom.isNotEmpty) tags.add(tenNhom);
      final dsCT = (nhom?["dsChiTietLoai"] ?? []) as List<dynamic>;
      if (dsCT.isNotEmpty) {
        final first = (dsCT.first?["tenChiTiet"] ?? "").toString();
        if (first.isNotEmpty) tags.add(first);
      }
    }
    return tags.isEmpty ? " " : tags.join(", ");
  }

  // icon minh hoạ từng dòng (theo index)
  Widget _leadingIcon(int i) {
    const icons = [
      Icons.brush,
      Icons.campaign,
      Icons.translate,
      Icons.movie_filter,
      Icons.music_note,
      Icons.computer,
      Icons.storage,
      Icons.business_center,
    ];
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icons[i % icons.length], color: Colors.black87),
    );
  }
}
