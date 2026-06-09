import 'package:flutter/material.dart';

/// Modern confirmation dialog with an icon badge and two full-width buttons.
/// Defaults to a destructive (red) style; pass [confirmColor]/[icon] to change.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
  Color confirmColor = const Color(0xFFDC2626),
  IconData icon = Icons.warning_amber_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: confirmColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(cancelLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
