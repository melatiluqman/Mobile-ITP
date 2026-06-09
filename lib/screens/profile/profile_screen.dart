import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final roleLabel = AppConstants.roleLabels[user.role] ?? user.role;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFDC2626),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFORMASI AKUN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                _InfoCard(
                  icon: Icons.person_outline,
                  label: 'Nama Lengkap',
                  value: user.name,
                ),
                _InfoCard(
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: '@${user.username}',
                ),
                _InfoCard(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: roleLabel,
                ),
                if (user.phone != null && user.phone!.isNotEmpty)
                  _InfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Nomor HP',
                    value: user.phone!,
                  ),

                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    onPressed: () async {
                      final confirmed = await showConfirmDialog(
                        context,
                        title: 'Logout',
                        content: 'Yakin ingin keluar dari akun ini?',
                        confirmLabel: 'Logout',
                        icon: Icons.logout,
                      );
                      if (confirmed && context.mounted) {
                        await context.read<AuthProvider>().logout();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF0F172A), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
