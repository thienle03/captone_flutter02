import 'package:flutter/material.dart';

class EditDescriptionSheet extends StatefulWidget {
  final Map<String, dynamic> user;
  final Future<void> Function(Map<String, dynamic> patch) onSave;

  const EditDescriptionSheet({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditDescriptionSheet> createState() => _EditDescriptionSheetState();
}

class _EditDescriptionSheetState extends State<EditDescriptionSheet> {
  late TextEditingController nameCtl;
  late TextEditingController emailCtl;
  late TextEditingController phoneCtl;
  late TextEditingController birthdayCtl;
  late bool gender;
  late String role;

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.user["name"] ?? "");
    emailCtl = TextEditingController(text: widget.user["email"] ?? "");
    phoneCtl = TextEditingController(text: widget.user["phone"] ?? "");
    birthdayCtl = TextEditingController(text: widget.user["birthday"] ?? "");
    gender = (widget.user["gender"] ?? true) == true;
    role = widget.user["role"] ?? "USER";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // 👈 quan trọng để modal co theo nội dung
          children: [
            const Text(
              "Edit Description",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailCtl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneCtl,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: birthdayCtl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Birthday (yyyy-MM-dd)",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );
                    if (picked != null) {
                      birthdayCtl.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text("Gender (Male)"),
              value: gender,
              onChanged: (v) => setState(() => gender = v),
            ),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "USER", child: Text("USER")),
              ],
              onChanged: (v) => setState(() => role = v ?? "USER"),
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final patch = {
                    "name": nameCtl.text.trim(),
                    "email": emailCtl.text.trim(),
                    "phone": phoneCtl.text.trim(),
                    "birthday": birthdayCtl.text.trim(),
                    "gender": gender,
                    "role": role,
                  };
                  Navigator.pop(context);
                  await widget.onSave(patch);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
