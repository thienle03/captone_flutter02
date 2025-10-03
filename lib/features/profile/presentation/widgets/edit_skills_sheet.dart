import 'package:flutter/material.dart';

class EditSkillsSheet extends StatefulWidget {
  final List<String> allSkills;
  final Set<String> current;
  final Future<bool> Function(List<String>) onSave;

  const EditSkillsSheet({
    super.key,
    required this.allSkills,
    required this.current,
    required this.onSave,
  });

  @override
  State<EditSkillsSheet> createState() => _EditSkillsSheetState();
}

class _EditSkillsSheetState extends State<EditSkillsSheet> {
  final searchCtl = TextEditingController();
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = {...widget.current};
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchCtl.text.trim().toLowerCase();
    // ✅ nếu keyword rỗng -> hiện tất cả; có chữ -> lọc
    final filtered = keyword.isEmpty
        ? widget.allSkills
        : widget.allSkills
            .where((s) => s.toLowerCase().contains(keyword))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Chọn kỹ năng",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: searchCtl,
            decoration: const InputDecoration(
              hintText: "Tìm skill...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered.map((s) {
                  final isSel = selected.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: isSel,
                    onSelected: (v) {
                      setState(() => v ? selected.add(s) : selected.remove(s));
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selected.map((s) => Chip(label: Text(s))).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy")),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await widget.onSave(selected.toList());
                  if (ok && context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text("Lưu"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
