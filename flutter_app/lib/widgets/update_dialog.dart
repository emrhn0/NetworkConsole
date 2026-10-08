import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/i18n.dart';
import '../core/update_checker.dart';
import '../theme/app_colors.dart';

/// Downloads and installs [info], then quits so the update can replace this
/// app's files; the update relaunches it. Only returns if something went
/// wrong, with the reason. Shared by the launch prompt and the Settings page,
/// which offer the same update in two places.
Future<String?> installUpdate(UpdateInfo info,
    {void Function(double? progress)? onProgress}) async {
  final error = await UpdateChecker.downloadAndInstall(info, onProgress: onProgress);
  if (error != null) return error;
  exit(0);
}

/// Shows the "a new version is available" prompt for [info].
Future<void> showUpdateDialog(BuildContext context, UpdateInfo info,
    {required AppColors c, required String lang}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(info: info, c: c, lang: lang),
  );
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.info, required this.c, required this.lang});
  final UpdateInfo info;
  final AppColors c;
  final String lang;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _busy = false;
  double? _progress;
  String? _error;

  Future<void> _install() async {
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    final error = await installUpdate(
      widget.info,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  Future<void> _openPage() async {
    await UpdateChecker.openReleasePage(widget.info);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final lang = widget.lang;
    final info = widget.info;
    final notes = info.plainNotes;
    final size = info.sizeLabel;

    return AlertDialog(
      backgroundColor: c.bgRise,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.lineSoft),
      ),
      title: Row(children: [
        Icon(Icons.system_update_alt, size: 18, color: c.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Network Console ${info.version}',
              style: TextStyle(color: c.ink, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ]),
      content: SizedBox(
        width: 440,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${tf(lang, 'update.running', [kAppVersion])}'
            '${size.isEmpty ? '' : ' ${tf(lang, 'update.size', [size])}'}',
            style: TextStyle(color: c.inkFaint, fontSize: 12),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Text(notes, style: TextStyle(color: c.inkSoft, fontSize: 12, height: 1.45)),
              ),
            ),
          ],
          if (!info.canSelfInstall) ...[
            const SizedBox(height: 14),
            Text(t(lang, 'update.manualNote'),
                style: TextStyle(color: c.inkFaint, fontSize: 12, height: 1.4)),
          ],
          if (_busy) ...[
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress, backgroundColor: c.fillHover, color: c.accent, minHeight: 6),
            ),
            const SizedBox(height: 8),
            Text(
              _progress == null
                  ? t(lang, 'update.downloading')
                  : '${t(lang, 'update.downloading')} ${(_progress! * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.spaceMono(color: c.inkFaint, fontSize: 11),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: TextStyle(color: c.alarm, fontSize: 12)),
            const SizedBox(height: 6),
            Text(t(lang, 'update.errorHint'), style: TextStyle(color: c.inkFaint, fontSize: 11)),
          ],
        ]),
      ),
      actions: _busy
          ? const []
          : [
              TextButton(
                onPressed: () async {
                  await UpdateChecker.skip(widget.info.version);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(t(lang, 'action.skipVersion'), style: TextStyle(color: c.inkGhost)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t(lang, 'action.remindLater'), style: TextStyle(color: c.inkFaint)),
              ),
              if (info.canSelfInstall && _error == null)
                TextButton(
                  onPressed: _install,
                  child: Text(t(lang, 'action.updateNow'),
                      style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
                )
              else
                TextButton(
                  onPressed: _openPage,
                  child: Text(t(lang, 'action.openDownloadPage'),
                      style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
                ),
            ],
    );
  }
}
