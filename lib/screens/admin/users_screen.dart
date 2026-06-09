import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/admin/create_user_sheet.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: const CreateUserSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Users'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSheet,
        backgroundColor: const Color(0xFFDC2626),
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text('Tambah Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) return const LoadingView();
          if (provider.error != null && provider.users.isEmpty) {
            return ErrorView(message: provider.error!, onRetry: provider.loadUsers);
          }
          if (provider.users.isEmpty) {
            return const EmptyView(message: 'Tidak ada user', icon: Icons.people_outline);
          }
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: RefreshIndicator(
              color: const Color(0xFFDC2626),
              onRefresh: provider.loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: provider.users.length,
                itemBuilder: (context, i) => _UserCard(
                  user: provider.users[i],
                  onDelete: (id) async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Hapus User',
                      content: 'Yakin ingin menghapus user ini?',
                    );
                    if (confirmed && context.mounted) {
                      provider.deleteUser(id, onError: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.red),
                        );
                      });
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final void Function(int) onDelete;
  const _UserCard({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final roleLabel = AppConstants.roleLabels[user.role] ?? user.role;
    final color = kRoleColors[user.role] ?? const Color(0xFF64748B);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withAlpha(20),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('@${user.username}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      roleLabel,
                      style: TextStyle(
                          fontSize: 11, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (!user.isSuperAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                onPressed: () => onDelete(user.id),
              ),
          ],
        ),
      ),
    );
  }
}
