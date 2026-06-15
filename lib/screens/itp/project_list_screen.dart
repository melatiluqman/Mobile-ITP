import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/project_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../core/constants.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  static const _primary = Color(0xFFDC2626);
  static const _navy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItpProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ITP System'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final user = auth.user;
              if (user == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _primary.withAlpha(80)),
                      ),
                      child: Text(
                        AppConstants.roleLabels[user.role]?.toUpperCase() ?? user.role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFCA5A5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primary, Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<ItpProvider, AuthProvider>(
        builder: (context, provider, auth, child) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const LoadingView();
          }
          if (provider.error != null && provider.projects.isEmpty) {
            return ErrorView(
              message: provider.error!,
              onRetry: () => provider.loadProjects(),
            );
          }

          return RefreshIndicator(
            color: _primary,
            onRefresh: () => provider.loadProjects(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroSection(
                    userName: auth.user?.name ?? '',
                    projectCount: provider.projects.length,
                    role: auth.user != null
                        ? (AppConstants.roleLabels[auth.user!.role] ?? auth.user!.role)
                        : '',
                  ),
                ),
                if (provider.projects.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyView(
                      message: 'Tidak ada proyek yang ditugaskan',
                      icon: Icons.folder_off_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + MediaQuery.of(context).padding.bottom),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 272,
                      ),
                      itemCount: provider.projects.length,
                      itemBuilder: (context, i) => _ProjectCard(
                        project: provider.projects[i],
                        colorIndex: i,
                      ),
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

class _HeroSection extends StatelessWidget {
  final String userName;
  final int projectCount;
  final String role;

  const _HeroSection({
    required this.userName,
    required this.projectCount,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.anchor, color: Color(0xFFDC2626), size: 32),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFF1E293B)],
            ).createShader(bounds),
            child: Text(
              'Selamat Datang${userName.isNotEmpty ? ', $userName' : ''}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Akses dashboard monitoring ITP untuk setiap proyek Anda',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(value: '$projectCount', label: 'Proyek Aktif'),
              Container(
                width: 1,
                height: 28,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _StatChip(value: role, label: 'Akses Role'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFFDC2626),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int colorIndex;

  const _ProjectCard({required this.project, required this.colorIndex});

  static const _iconGradients = [
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFFEF4444), Color(0xFFDC2626)],
    [Color(0xFF06B6D4), Color(0xFF0891B2)],
  ];

  @override
  Widget build(BuildContext context) {
    final progress = project.progress;
    final percent = progress?.percent ?? 0;
    final colors = _iconGradients[colorIndex % _iconGradients.length];
    final deadlineBadge = _buildDeadlineBadge(project.deadline);

    return GestureDetector(
      onTap: () => context.go('/home/projects/${project.id}/moduls'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colors[0].withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_boat, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      project.kodeProject,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      project.namaProject,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.tanggalMulai != null) ...[
                      const SizedBox(height: 6),
                      _MetaItem(
                        icon: Icons.play_circle_outline,
                        text: _formatDate(project.tanggalMulai!),
                      ),
                    ],
                    if (project.deadline != null) ...[
                      const SizedBox(height: 2),
                      _MetaItem(
                        icon: Icons.flag_outlined,
                        text: _formatDate(project.deadline!),
                      ),
                    ],
                    if (deadlineBadge != null) ...[
                      const SizedBox(height: 6),
                      deadlineBadge,
                    ],
                  ],
                ),
              ),
            ),

            // Footer: progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFBFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: percent == 100 ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent == 100 ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress?.done ?? 0} dari ${progress?.total ?? 0}',
                        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
                      ),
                      if (percent == 100)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 10),
                            SizedBox(width: 2),
                            Text(
                              'Tuntas',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildDeadlineBadge(String? deadline) {
    if (deadline == null) return null;
    final dl = DateTime.tryParse(deadline);
    if (dl == null) return null;
    final diff = dl.difference(DateTime.now()).inDays;

    Color bg, textColor, borderColor;
    IconData icon;
    String text;

    if (diff < 0) {
      bg = const Color(0xFFFEF2F2);
      textColor = const Color(0xFF991B1B);
      borderColor = const Color(0xFFFECACA);
      icon = Icons.error_outline;
      text = 'Overdue ${diff.abs()}h';
    } else if (diff <= 7) {
      bg = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFDC2626);
      borderColor = const Color(0xFFFEE2E2);
      icon = Icons.schedule;
      text = '$diff hari lagi!';
    } else if (diff <= 30) {
      bg = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFD97706);
      borderColor = const Color(0xFFFDE68A);
      icon = Icons.schedule;
      text = '$diff hari lagi';
    } else {
      bg = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF059669);
      borderColor = const Color(0xFFBBF7D0);
      icon = Icons.calendar_today_outlined;
      text = _formatDate(deadline);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: textColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
