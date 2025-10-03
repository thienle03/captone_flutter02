import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_request.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _birthday = TextEditingController();

  bool _gender = true; // true = Male
  bool _obscure = true;
  bool _isLoading = false;

  final _repo = AuthRepository();

  Future<void> _pickBirthday() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _birthday.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final req = UserRequest(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: _phone.text.trim(),
      birthday: _birthday.text,
      gender: _gender,
      role: "USER",
    );

    final res = await _repo.signUp(req);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thất bại: ${res.body}")),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _birthday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name
          TextFormField(
            controller: _name,
            decoration: _filledInput(label: "Name", icon: Icons.person_outline),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Nhập tên" : null,
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _filledInput(label: "Email", icon: Icons.mail_outlined),
            validator: (v) =>
                (v == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(v))
                    ? "Email không hợp lệ"
                    : null,
          ),
          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration:
                _filledInput(label: "Password", icon: Icons.lock_outline)
                    .copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? "Mật khẩu >= 6 ký tự" : null,
          ),
          const SizedBox(height: 12),

          // Phone
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration:
                _filledInput(label: "Phone", icon: Icons.phone_outlined),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Nhập số điện thoại" : null,
          ),
          const SizedBox(height: 12),

          // Birthday
          TextFormField(
            controller: _birthday,
            readOnly: true,
            onTap: _pickBirthday,
            decoration: _filledInput(
              label: "Birthday (yyyy-MM-dd)",
              icon: Icons.cake_outlined,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? "Chọn ngày sinh" : null,
          ),
          const SizedBox(height: 12),

          // Gender
          DropdownButtonFormField<String>(
            value: _gender ? "Male" : "Female",
            decoration: _filledInput(label: "Gender", icon: Icons.wc),
            items: const [
              DropdownMenuItem(value: "Male", child: Text("Male")),
              DropdownMenuItem(value: "Female", child: Text("Female")),
            ],
            onChanged: (v) => setState(() => _gender = (v == "Male")),
          ),
          const SizedBox(height: 18),

          // Submit
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
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
          const SizedBox(height: 10),

          // Switch to Login
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text("Đã có tài khoản? Đăng nhập"),
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
