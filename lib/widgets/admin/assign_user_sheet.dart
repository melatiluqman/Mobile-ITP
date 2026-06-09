import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants.dart';
import 'create_user_sheet.dart' show kRoleColors;

/// Modern bottom-sheet to assign a user to a project.
/// Open with [showModalBottomSheet] (isScrollControlled: true, useSafeArea: true).
class AssignUserSheet extends StatefulWidget {
  final int projectId;
  const AssignUserSheet({required this.projectId, super.key});

  @override
  State<AssignUserSheet> createState() => _AssignUserSheetState();
}

class _AssignUserSheetState extends State<AssignUserSheet> {
  int? _selectedUserId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminProvider>();
      if (p.users.isEmpty) p.loadUsers();
    });
  }

  Future<void> _submit() async {
    if (_selectedUserId == null) return;
    setState(() => _loading = true);
    final provider = context.read<AdminProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.assignUser(
      widget.projectId,
      _selectedUserId!,
      onError: (msg) => messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (ok) await provider.loadDashboard();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('User berhasil di-assign'), backgroundColor: Color(0xFF10B981)),
      );
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group_add_outlined, color: Color(0xFF3B82F6), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assign User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Tugaskan pengguna ke proyek ini',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          Flexible(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                final users = provider.users.where((u) => !u.isSuperAdmin).toList();
                if (provider.isLoading && users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
                  );
                }
                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada user untuk di-assign',
                          style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _UserOption(
                    user: users[i],
                    selected: _selectedUserId == users[i].id,
                    onTap: () => setState(() => _selectedUserId = users[i].id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: (_loading || _selectedUserId == null) ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Assign User',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserOption extends StatelessWidget {
  final UserModel user;
  final bool selected;
  final VoidCallback onTap;
  const _UserOption({required this.user, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = kRoleColors[user.role] ?? const Color(0xFF64748B);
    final roleLabel = AppConstants.roleLabels[user.role] ?? user.role;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6).withAlpha(12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withAlpha(20),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('@${user.username}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(roleLabel,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
