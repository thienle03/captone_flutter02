import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_repository.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  final _repo = AuthRepository();

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _repo.signin(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (response.statusCode == 200) {
        dynamic raw;
        try {
          raw = jsonDecode(response.body);
        } catch (_) {}
        final content = (raw is Map) ? raw["content"] ?? raw : raw;
        final user = (content is Map) ? (content["user"] ?? content) : null;
        final userId = (user?["id"]) ?? (content?["id"]);

        if (userId == null) throw "UserId not found in the response.";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("userId", userId);
        await prefs.setString("email", (user?["email"] ?? "").toString());
        await prefs.setString("name", (user?["name"] ?? "").toString());

        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login successful")));
        hideKeyboard();

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        if (!mounted) return;

        String message;
        if (response.statusCode == 401) {
          message = "❌ Invalid email or password, please try again";
        } else if (response.statusCode == 500) {
          message = "❌ Server error, please try again later";
        } else {
          message = "❌ Login failed (error code ${response.statusCode})";
        }

// Log chi tiết cho dev
        debugPrint("Login failed: ${response.statusCode} ${response.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Connection error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _filledInput(
              label: 'Email',
              icon: Icons.mail_outlined,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Input email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: _filledInput(
              label: 'Password',
              icon: Icons.lock_outline,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Input the password.' : null,
          ),
          const SizedBox(height: 18),
          _isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 72, 236, 80),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1.5,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text("Don't have an account? Sign up now."),
          ),
        ],
      ),
    );
  }

  InputDecoration _filledInput(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }
}
