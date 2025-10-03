class SearchUtils {
  /// Tạo danh sách tag gợi ý từ JSON menu
  static List<String> buildSuggestTags(List<dynamic> menu) {
    final set = <String>{};
    for (final loai in menu) {
      final dsNhom = (loai?["dsNhomChiTietLoai"] ?? []) as List<dynamic>;
      for (final nhom in dsNhom) {
        final dsCT = (nhom?["dsChiTietLoai"] ?? []) as List<dynamic>;
        for (final ct in dsCT) {
          final name = (ct?["tenChiTiet"] ?? "").toString().trim();
          if (name.isNotEmpty) set.add(name);
          if (set.length >= 12) break;
        }
        if (set.length >= 12) break;
      }
      if (set.length >= 12) break;
    }

    if (set.isEmpty) {
      set.addAll(["graphic design", "website", "logo", "seo", "app design"]);
    }
    return set.toList();
  }
}
