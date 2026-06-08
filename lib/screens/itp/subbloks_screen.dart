import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/itp_provider.dart';
import '../../models/subblok_model.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/loading_overlay.dart';

class SubBloksScreen extends StatefulWidget {
  final int blokId;
  const SubBloksScreen({required this.blokId, super.key});

  @override
  State<SubBloksScreen> createState() => _SubBloksScreenState();
}

class _SubBloksScreenState extends State<SubBloksScreen> {
  List<SubBlokModel> _subbloks = [];
  String _blokName = '';
  bool _loading = true;
  String? _error;

  static const _primary = Color(0xFFDC2626);
  static const _navy = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await context.read<ItpProvider>().getSubBloks(widget.blokId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result != null) {
          _subbloks = result['subbloks'] as List<SubBlokModel>;
          final b = result['blok'];
          _blokName = b is Map ? b['nama_blok'] as String? ?? '' : '';
        } else {
          _error = context.read<ItpProvider>().error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final basePath = currentPath.contains('/bloks')
        ? '${currentPath.split('/bloks').first}/bloks/${widget.blokId}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_blokName.isEmpty ? 'Sub Blok' : _blokName),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _subbloks.isEmpty
                  ? const EmptyView(message: 'Tidak ada sub blok')
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _subbloks.length,
                        itemBuilder: (context, i) => _SubBlokCard(
                          subblok: _subbloks[i],
                          basePath: basePath,
                        ),
                      ),
                    ),
    );
  }
}

class _SubBlokCard extends StatelessWidget {
  final SubBlokModel subblok;
  final String basePath;
  const _SubBlokCard({required this.subblok, required this.basePath});

  static const _primary = Color(0xFFDC2626);
  static const _success = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final percent = subblok.progress.percent;
    final progressColor = percent == 100 ? _success : _primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('$basePath/subbloks/${subblok.id}/assembly'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.grid_view_outlined, color: _primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subblok.namaSubBlok,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${subblok.progress.done}/${subblok.progress.total} item',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
