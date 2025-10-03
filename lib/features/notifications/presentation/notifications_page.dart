import 'package:flutter/material.dart';
import '../../notifications/data/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await NotificationService.fetchAll();
    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });

    // đánh dấu đã đọc hết
    await NotificationService.markAllRead();
  }

  Future<void> _clearAll() async {
    await NotificationService.clear();
    if (!mounted) return;
    setState(() => _items = []);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xoá tất cả thông báo")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        actions: [
          IconButton(
            tooltip: "Delete all",
            onPressed: _items.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 182, 235, 204),
              Color.fromARGB(255, 233, 241, 240),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text("No notifications"))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final n = _items[i];
                          final icon = n.type == "order"
                              ? Icons.shopping_bag_outlined
                              : n.type == "done"
                                  ? Icons.check_circle_outline
                                  : Icons.notifications_none;

                          return Dismissible(
                            key: ValueKey(n.id),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async => true,
                            onDismissed: (_) async {
                              final removed = n;
                              setState(() => _items.removeAt(i));
                              await NotificationService.remove(removed.id);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Deleted 1 notification"),
                                  action: SnackBarAction(
                                    label: "Undo",
                                    onPressed: () async {
                                      await NotificationService.add(
                                        type: removed.type,
                                        title: removed.title,
                                        body: removed.body,
                                      );
                                      _load();
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child:
                                      Icon(icon, color: Colors.green.shade700),
                                ),
                                title: Text(
                                  n.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(n.body),
                                trailing: Text(
                                  _fmt(n.createdAt),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  String _fmt(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
