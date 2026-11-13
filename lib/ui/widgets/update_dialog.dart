import 'package:flutter/material.dart';

import '../../services/update_service.dart';

/// Patch notes + "Update now" / "Later". With [readOnly] it just shows the
/// notes (used for "What's new" after an update).
class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  final UpdateService service;
  final AppInstaller installer;
  final bool readOnly;

  const UpdateDialog({
    super.key,
    required this.info,
    required this.service,
    required this.installer,
    this.readOnly = false,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double? _progress;
  String? _error;

  Future<void> _update() async {
    setState(() {
      _error = null;
      _progress = 0;
    });
    try {
      if (!await widget.installer.canInstall()) {
        if (!mounted) return;
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Allow installing updates'),
            content: const Text(
              'Android needs your permission for this app to install an '
              'update. Turn on "Allow from this source", come back, and tap '
              '"Update now" again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (go == true) await widget.installer.openInstallPermission();
        if (mounted) setState(() => _progress = null);
        return;
      }
      final path = await widget.service.download(
        widget.info,
        onProgress: (f) {
          if (mounted) setState(() => _progress = f);
        },
      );
      await widget.installer.installApk(path);
      if (mounted) setState(() => _progress = null);
    } catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final lines = info.notes
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return AlertDialog(
      title: Text(
        widget.readOnly
            ? "What's new in ${info.version}"
            : 'New version ${info.version} available',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.startsWith('- ') ? '•  ${l.substring(2)}' : l),
                ),
              if (_progress != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _progress),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _progress != null ? null : () => Navigator.pop(context),
          child: Text(widget.readOnly ? 'Close' : 'Later'),
        ),
        if (!widget.readOnly)
          FilledButton(
            onPressed: _progress != null ? null : _update,
            child: const Text('Update now'),
          ),
      ],
    );
  }
}
