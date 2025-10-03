import 'package:fiverr/services/search_service.dart';

class SearchRepository {
  final SearchService _service = SearchService();

  Future<List<dynamic>> fetchLoaiCongViec() {
    return _service.fetchLoaiCongViec();
  }

  Future<List<dynamic>> searchJobs(String keyword) {
    return _service.searchJobs(keyword);
  }
}
