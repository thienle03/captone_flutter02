import 'package:fiverr/services/search_service.dart';

class JobRepository {
  Future<List<dynamic>> searchJobs(String keyword) {
    return SearchService().searchJobs(keyword);
  }
}
