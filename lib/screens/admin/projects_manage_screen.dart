import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';
import '../../core/constants.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProjectsManageScreen extends StatefulWidget {
  const ProjectsManageScreen({super.key});

  @override
  State<ProjectsManageScreen> createState() => _ProjectsManageScreenState();
}

class _ProjectsManageScreenState extends State<ProjectsManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
      context.read<AdminProvider>().loadTemplates();
    });
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: const _CreateProjectSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Proyek'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFDC2626),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          final projects = provider.dashboard?.projects ?? [];
          if (provider.isLoading && projects.isEmpty) return const LoadingView();
          if (provider.error != null && projects.isEmpty) {
            return ErrorView(message: provider.error!, onRetry: provider.loadDashboard);
          }
          if (projects.isEmpty) {
            return const EmptyView(message: 'Tidak ada proyek', icon: Icons.folder_off_outlined);
          }
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: RefreshIndicator(
              color: const Color(0xFFDC2626),
              onRefresh: () async {
                await provider.loadDashboard();
                await provider.loadTemplates();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: projects.length,
                itemBuilder: (context, i) => _ProjectManageCard(
                  project: projects[i],
                  provider: provider,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectManageCard extends StatelessWidget {
  final ProjectModel project;
  final AdminProvider provider;
  const _ProjectManageCard({required this.project, required this.provider});

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AssignUserDialog(projectId: project.id, provider: provider),
    );
  }

  Future<void> _unassign(BuildContext context, UserModel user) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Unassign User',
      content: 'Lepas "${user.name}" dari proyek ini?',
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await provider.unassignUser(
      project.id,
      user.id,
      onError: (msg) => messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    await provider.loadDashboard();
    messenger.showSnackBar(
      const SnackBar(content: Text('User berhasil di-unassign'), backgroundColor: Color(0xFF10B981)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = project.status == 'active';
    final progress = project.progress?.percent ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.namaProject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(project.kodeProject,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
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

          // Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
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
          if (project.tanggalMulai != null || project.deadline != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  if (project.tanggalMulai != null) ...[
                    const Icon(Icons.play_circle_outline, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(project.tanggalMulai!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(width: 12),
                  ],
                  if (project.deadline != null) ...[
                    const Icon(Icons.flag_outlined, size: 13, color: Color(0xFFDC2626)),
                    const SizedBox(width: 3),
                    Text(project.deadline!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                  ],
                ],
              ),
            ),

          // Assigned users
          if (project.assignedUsers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text('USER DITUGASKAN',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      letterSpacing: 0.8, color: Color(0xFF94A3B8))),
            ),
            ...project.assignedUsers.map((u) => _AssignedUserRow(
                  user: u,
                  onUnassign: () => _unassign(context, u),
                )),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showAssignDialog(context),
                  icon: const Icon(Icons.person_add_outlined, size: 14),
                  label: const Text('Assign User', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      context.push('/admin/projects/${project.id}/structure'),
                  icon: const Icon(Icons.account_tree_outlined, size: 14),
                  label: const Text('Kelola Struktur', style: TextStyle(fontSize: 12)),
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

class _AssignedUserRow extends StatelessWidget {
  final UserModel user;
  final VoidCallback onUnassign;
  const _AssignedUserRow({required this.user, required this.onUnassign});

  @override
  Widget build(BuildContext context) {
    final roleLabel = AppConstants.roleLabels[user.role] ?? user.role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF0F172A).withAlpha(15),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${user.name} · $roleLabel',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onUnassign,
            child: const Icon(Icons.link_off, size: 16, color: Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}

class _CreateProjectSheet extends StatefulWidget {
  const _CreateProjectSheet();

  @override
  State<_CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<_CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _kodeCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  int? _selectedTemplateId;
  bool _loading = false;

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
    if (picked != null && mounted) {
      setState(() => ctrl.text = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<AdminProvider>().createProject(
      namaProject: _namaCtrl.text.trim(),
      kodeProject: _kodeCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim().isEmpty ? null : _deskripsiCtrl.text.trim(),
      tanggalMulai: _startCtrl.text.isEmpty ? null : _startCtrl.text,
      deadline: _deadlineCtrl.text.isEmpty ? null : _deadlineCtrl.text,
      templateId: _selectedTemplateId,
      onError: (msg) => messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      ),
    );
    if (mounted) setState(() => _loading = false);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Proyek berhasil dibuat'), backgroundColor: Color(0xFF10B981)),
      );
      nav.pop();
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<AdminProvider>().templates;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.create_new_folder_outlined,
                      color: Color(0xFFDC2626), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buat Proyek',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Tambahkan proyek baru',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: _inputDecoration('Nama Proyek', Icons.folder_outlined),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _kodeCtrl,
                      decoration: _inputDecoration('Kode Proyek', Icons.tag),
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _deskripsiCtrl,
                      decoration: _inputDecoration('Deskripsi (opsional)', Icons.notes_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    // Date row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startCtrl,
                            readOnly: true,
                            onTap: () => _pickDate(_startCtrl),
                            decoration: _inputDecoration(
                              'Tanggal Mulai',
                              Icons.play_circle_outline,
                              suffix: const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _deadlineCtrl,
                            readOnly: true,
                            onTap: () => _pickDate(_deadlineCtrl),
                            decoration: _inputDecoration(
                              'Deadline',
                              Icons.flag_outlined,
                              suffix: const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (templates.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedTemplateId,
                        decoration: _inputDecoration('Template (opsional)', Icons.copy_outlined),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Tanpa Template')),
                          ...templates.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                        ],
                        onChanged: (v) => setState(() => _selectedTemplateId = v),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Buat Proyek',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignUserDialog extends StatefulWidget {
  final int projectId;
  final AdminProvider provider;
  const _AssignUserDialog({required this.projectId, required this.provider});

  @override
  State<_AssignUserDialog> createState() => _AssignUserDialogState();
}

class _AssignUserDialogState extends State<_AssignUserDialog> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final users = widget.provider.users;
    if (users.isEmpty) {
      widget.provider.loadUsers();
    }
    return AlertDialog(
      title: const Text('Assign User ke Proyek'),
      content: users.isEmpty
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : DropdownButtonFormField<int>(
              initialValue: _selectedUserId,
              decoration: const InputDecoration(labelText: 'Pilih User', border: OutlineInputBorder()),
              items: users
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
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
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
                    await widget.provider.loadDashboard();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User berhasil di-assign'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  }
                },
          child: const Text('Assign', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
