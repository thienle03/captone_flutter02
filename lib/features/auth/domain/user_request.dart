class UserRequest {
  final int id;
  final String name, email, password, phone, birthday; // yyyy-MM-dd
  final bool gender;
  final String role;
  final List<String> skill, certification;

  const UserRequest({
    this.id = 0,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.birthday,
    required this.gender,
    this.role = "USER",
    this.skill = const [],
    this.certification = const [],
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name.trim(),
        "email": email.trim(),
        "password": password.trim(),
        "phone": phone.trim(),
        "birthday": birthday.trim(),
        "gender": gender,
        "role": role,
        "skill": skill,
        "certification": certification,
      };
}
