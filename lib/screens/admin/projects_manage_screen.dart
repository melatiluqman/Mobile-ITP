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
import '../../widgets/admin/create_project_sheet.dart';
import '../../widgets/admin/assign_user_sheet.dart';

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
        child: const CreateProjectSheet(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: AssignUserSheet(projectId: project.id),
      ),
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
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showAssignDialog(context),
                    icon: const Icon(Icons.person_add_outlined, size: 14),
                    label: const Text(
                      'Assign User',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push('/admin/projects/${project.id}/structure'),
                    icon: const Icon(Icons.account_tree_outlined, size: 14),
                    label: const Text(
                      'Kelola Struktur',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
                  ),
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
