import 'package:fiverr/services/category_service.dart';

class CategoryRepository {
  Future<List<dynamic>> fetchMenuLoai() {
    return CategoryService.fetchMenuLoai();
  }
}
