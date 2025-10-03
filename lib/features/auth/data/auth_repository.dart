import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../domain/user_request.dart';

class AuthRepository {
  Future<http.Response> signUp(UserRequest req) {
    return ApiService.signUp(req.toJson());
  }

  Future<http.Response> signin(String email, String password) {
    return ApiService.signIn(email, password);
  }
}
