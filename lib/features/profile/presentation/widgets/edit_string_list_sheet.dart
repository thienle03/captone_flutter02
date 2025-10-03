import 'package:flutter/material.dart';

class EditStringListSheet extends StatefulWidget {
  final String fieldLabel;
  final List<String> current;
  final Future<void> Function(List<String> newList) onSave;

  const EditStringListSheet({
    super.key,
    required this.fieldLabel,
    required this.current,
    required this.onSave,
  });

  @override
  State<EditStringListSheet> createState() => _EditStringListSheetState();
}

class _EditStringListSheetState extends State<EditStringListSheet> {
  late TextEditingController ctl;

  @override
  void initState() {
    super.initState();
    ctl = TextEditingController(text: widget.current.join("\n"));
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
        // 👈 bọc Column trong scroll
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit ${widget.fieldLabel}",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Mỗi dòng là một mục",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final lines = ctl.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  Navigator.pop(context);
                  await widget.onSave(lines);
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
