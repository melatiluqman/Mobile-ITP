import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';
import '../../core/constants.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String _filterRole = 'all';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadActivityLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminProvider>().loadActivityLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    label: 'Role',
                    value: _filterRole,
                    items: {
                      'all': 'Semua Role',
                      ...{for (final r in AppConstants.roles) r: AppConstants.roleLabels[r] ?? r},
                    },
                    onChanged: (v) => setState(() => _filterRole = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterDropdown(
                    label: 'Status',
                    value: _filterStatus,
                    items: const {
                      'all': 'Semua Status',
                      'done': 'Selesai',
                      'approved': 'Disetujui',
                      'needs_revision': 'Revisi',
                    },
                    onChanged: (v) => setState(() => _filterStatus = v),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.logsLoading && provider.activityLogs.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)));
                }
                if (provider.error != null && provider.activityLogs.isEmpty) {
                  return ErrorView(message: provider.error!, onRetry: provider.loadActivityLogs);
                }

                final logs = provider.activityLogs.where((l) {
                  final roleOk = _filterRole == 'all' || l.userRole == _filterRole;
                  final statusOk = _filterStatus == 'all' || l.status == _filterStatus;
                  return roleOk && statusOk;
                }).toList();

                if (logs.isEmpty) {
                  return const EmptyView(message: 'Tidak ada log aktivitas', icon: Icons.history);
                }

                return RefreshIndicator(
                  color: const Color(0xFFDC2626),
                  onRefresh: provider.loadActivityLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, i) => _LogCard(log: logs[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items;
  final void Function(String) onChanged;
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: value,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12))))
            .toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      );
}

class _LogCard extends StatelessWidget {
  final ActivityLogModel log;
  const _LogCard({required this.log});

  Color get _statusColor {
    switch (log.status) {
      case 'approved': return const Color(0xFF10B981);
      case 'done': return const Color(0xFF3B82F6);
      case 'needs_revision': return const Color(0xFFF59E0B);
      default: return const Color(0xFF94A3B8);
    }
  }

  String get _statusLabel {
    switch (log.status) {
      case 'approved': return 'Disetujui';
      case 'done': return 'Selesai';
      case 'needs_revision': return 'Revisi';
      default: return log.status;
    }
  }

  Color get _roleColor {
    switch (log.userRole) {
      case 'admin': return const Color(0xFFDC2626);
      case 'admin_galangan': return const Color(0xFFDC2626);
      case 'yard': return const Color(0xFF3B82F6);
      case 'class': return const Color(0xFF10B981);
      case 'os': return const Color(0xFFF59E0B);
      case 'stat': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _roleColor.withAlpha(25),
                  child: Text(
                    log.userRole.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 11, color: _roleColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.userName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '${AppConstants.roleLabels[log.userRole] ?? log.userRole} · ${log.kodeProject}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(
                          fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ITP info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(log.itpCode,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${log.namaProject} › ${log.namaModul}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (log.keterangan != null && log.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(log.keterangan!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            if (log.rejectionNote != null && log.rejectionNote!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Catatan revisi: ${log.rejectionNote}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF92400E))),
                    ),
                  ],
                ),
              ),
            ],
            if (log.updatedAt != null) ...[
              const SizedBox(height: 6),
              Text(log.updatedAt!,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ],
        ),
      ),
    );
  }
}
