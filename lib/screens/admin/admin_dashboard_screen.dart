import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../core/constants.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/confirm_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminProvider>();
      p.loadDashboard();
      p.loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Log Aktivitas',
            onPressed: () => context.push('/admin/logs'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)));
          }
          if (provider.dashboard == null) {
            return ErrorView(
              message: provider.error ?? 'Gagal memuat data dashboard',
              onRetry: provider.loadDashboard,
            );
          }
          final dash = provider.dashboard!;
          return RefreshIndicator(
            color: const Color(0xFFDC2626),
            onRefresh: () async {
              await provider.loadDashboard();
              await provider.loadTemplates();
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DashboardHeader(dash: dash),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsRow(dash: dash),
                      const SizedBox(height: 20),
                      _QuickActions(provider: provider),
                      const SizedBox(height: 20),
                      _UsersSection(dash: dash, provider: provider),
                      const SizedBox(height: 20),
                      _ProjectsSection(dash: dash, provider: provider),
                      const SizedBox(height: 20),
                      _ActivitySection(activities: dash.recentActivity),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final DashboardStatsModel dash;
  const _DashboardHeader({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.anchor, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel Admin',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dash.totalProjects} proyek · ${dash.totalUsers} pengguna',
                  style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Stats row
// ──────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final DashboardStatsModel dash;
  const _StatsRow({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Users', value: dash.totalUsers, icon: Icons.people_outline, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        _StatCard(label: 'Proyek', value: dash.totalProjects, icon: Icons.folder_outlined, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        _StatCard(label: 'Modul', value: dash.totalModuls, icon: Icons.view_module_outlined, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        _StatCard(label: 'ITP', value: dash.totalItps, icon: Icons.assignment_outlined, color: const Color(0xFFDC2626)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────
// Quick Actions
// ──────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final AdminProvider provider;
  const _QuickActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKSI CEPAT',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.person_add_outlined,
                label: 'Tambah User',
                color: const Color(0xFF3B82F6),
                onTap: () => showDialog(context: context, builder: (_) => _CreateUserDialog(provider: provider)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.add_business_outlined,
                label: 'Tambah Proyek',
                color: const Color(0xFF10B981),
                onTap: () => showDialog(context: context, builder: (_) => _CreateProjectDialog(provider: provider)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────
// Users Section
// ──────────────────────────────────────────────────────────
class _UsersSection extends StatelessWidget {
  final DashboardStatsModel dash;
  final AdminProvider provider;
  const _UsersSection({required this.dash, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAFTAR PENGGUNA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Kelola akun pengguna sistem',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/admin/users'),
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (dash.users.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text('Belum ada pengguna', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...dash.users.map((user) => _UserRow(user: user, provider: provider)),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final UserModel user;
  final AdminProvider provider;
  const _UserRow({required this.user, required this.provider});

  Color get _roleColor {
    switch (user.role) {
      case 'admin': return const Color(0xFFDC2626);
      case 'yard': return const Color(0xFF3B82F6);
      case 'class': return const Color(0xFF10B981);
      case 'os': return const Color(0xFFF59E0B);
      case 'stat': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = AppConstants.roleLabels[user.role] ?? user.role;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _roleColor.withAlpha(25),
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: TextStyle(color: _roleColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '@${user.username}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(fontSize: 11, color: _roleColor, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (!user.isSuperAdmin) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Hapus User',
                    content: 'Yakin ingin menghapus "${user.name}"?',
                  );
                  if (confirmed && context.mounted) {
                    provider.deleteUser(user.id, onError: (msg) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.red),
                      );
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Projects Section
// ──────────────────────────────────────────────────────────
class _ProjectsSection extends StatelessWidget {
  final DashboardStatsModel dash;
  final AdminProvider provider;
  const _ProjectsSection({required this.dash, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAFTAR PROYEK',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Kelola proyek dan penugasan',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/admin/projects'),
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (dash.projects.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text('Belum ada proyek', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...dash.projects.map((p) => _ProjectRow(project: p, provider: provider, users: dash.users)),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final ProjectModel project;
  final AdminProvider provider;
  final List<UserModel> users;
  const _ProjectRow({required this.project, required this.provider, required this.users});

  @override
  Widget build(BuildContext context) {
    final isActive = project.status == 'active';
    final progress = project.progress?.percent ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: name, code, status switch
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.namaProject,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        project.kodeProject,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (_) => provider.toggleProjectStatus(project.id),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('$progress%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 100 ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dates
          if (project.deadline != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${project.deadline}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => _AssignUserDialog(
                      projectId: project.id,
                      provider: provider,
                      users: users,
                    ),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 14),
                  label: const Text('Assign', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push('/admin/projects/${project.id}/structure'),
                  icon: const Icon(Icons.account_tree_outlined, size: 14),
                  label: const Text('Struktur', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Activity Section
// ──────────────────────────────────────────────────────────
class _ActivitySection extends StatelessWidget {
  final List<ActivityItemModel> activities;
  const _ActivitySection({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKTIVITAS TERBARU',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Color(0xFF64748B)),
        ),
        const Text(
          'Entri ITP terbaru di semua proyek',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 10),
        if (activities.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text('Belum ada aktivitas', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...activities.take(10).map((a) => _ActivityTile(activity: a)),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItemModel activity;
  const _ActivityTile({required this.activity});

  Color get _statusColor {
    switch (activity.status) {
      case 'approved': return const Color(0xFF10B981);
      case 'done': return const Color(0xFF3B82F6);
      case 'needs_revision': return const Color(0xFFF59E0B);
      default: return const Color(0xFF94A3B8);
    }
  }

  String get _statusLabel {
    switch (activity.status) {
      case 'approved': return 'Disetujui';
      case 'done': return 'Selesai';
      case 'needs_revision': return 'Revisi';
      default: return activity.status;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: _statusColor.withAlpha(25),
            child: Text(
              activity.userRole.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            '${activity.itpCode} · ${activity.kodeProject}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            activity.userName,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusLabel, style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────
// Dialogs
// ──────────────────────────────────────────────────────────
class _CreateUserDialog extends StatefulWidget {
  final AdminProvider provider;
  const _CreateUserDialog({required this.provider});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'yard';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.provider.createUser(
      name: _nameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _role,
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_outlined, color: Color(0xFF3B82F6), size: 20),
          SizedBox(width: 8),
          Text('Tambah User', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Username wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 4) ? 'Min 4 karakter' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: AppConstants.roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(AppConstants.roleLabels[r] ?? r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? 'yard'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        Consumer<AdminProvider>(
          builder: (context, p, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
            onPressed: p.isLoading ? null : _submit,
            child: p.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan'),
          ),
        ),
      ],
    );
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final AdminProvider provider;
  const _CreateProjectDialog({required this.provider});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _kodeCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  int? _templateId;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _kodeCtrl.dispose();
    _deskripsiCtrl.dispose();
    _startCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) ctrl.text = picked.toIso8601String().split('T').first;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.provider.createProject(
      namaProject: _namaCtrl.text.trim(),
      kodeProject: _kodeCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim().isEmpty ? null : _deskripsiCtrl.text.trim(),
      tanggalMulai: _startCtrl.text.isEmpty ? null : _startCtrl.text,
      deadline: _deadlineCtrl.text.isEmpty ? null : _deadlineCtrl.text,
      templateId: _templateId,
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<AdminProvider>().templates;
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_business_outlined, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 8),
          Text('Buat Proyek', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Proyek', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _kodeCtrl,
                decoration: const InputDecoration(labelText: 'Kode Proyek', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _deskripsiCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _startCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 16),
                ),
                onTap: () => _pickDate(_startCtrl),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _deadlineCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 16),
                ),
                onTap: () => _pickDate(_deadlineCtrl),
              ),
              if (templates.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: _templateId,
                  decoration: const InputDecoration(labelText: 'Template (Opsional)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa Template')),
                    ...templates.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                  ],
                  onChanged: (v) => setState(() => _templateId = v),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        Consumer<AdminProvider>(
          builder: (context, p, _) => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: p.isLoading ? null : _submit,
            child: p.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan'),
          ),
        ),
      ],
    );
  }
}

class _AssignUserDialog extends StatefulWidget {
  final int projectId;
  final AdminProvider provider;
  final List<UserModel> users;
  const _AssignUserDialog({required this.projectId, required this.provider, required this.users});

  @override
  State<_AssignUserDialog> createState() => _AssignUserDialogState();
}

class _AssignUserDialogState extends State<_AssignUserDialog> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_outlined, color: Color(0xFF3B82F6), size: 20),
          SizedBox(width: 8),
          Text('Assign User', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: DropdownButtonFormField<int>(
        initialValue: _selectedUserId,
        decoration: const InputDecoration(labelText: 'Pilih Pengguna', border: OutlineInputBorder()),
        items: widget.users
            .where((u) => !u.isSuperAdmin)
            .map((u) => DropdownMenuItem(
                  value: u.id,
                  child: Text('${u.name} (${AppConstants.roleLabels[u.role] ?? u.role})'),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedUserId = v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
          onPressed: _selectedUserId == null
              ? null
              : () async {
                  final ok = await widget.provider.assignUser(
                    widget.projectId,
                    _selectedUserId!,
                    onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: Colors.red),
                    ),
                  );
                  if (ok && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User berhasil di-assign ke proyek'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
