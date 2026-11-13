import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';
import '../ui/widgets/update_dialog.dart';
import 'settings_service.dart';
import 'update_service.dart';

/// Start-up behaviour: one "What's new" after an update, and at most one
/// "new version" alert per release. Silent when offline.
class UpdateFlow {
  final SettingsService settings;
  final UpdateService service;
  final AppInstaller installer;
  final GlobalKey<NavigatorState> navigatorKey;

  UpdateFlow(this.settings, this.service, this.installer, this.navigatorKey);

  static const recheckAfter = Duration(hours: 6);

  Future<void> run() async {
    final package = await PackageInfo.fromPlatform();
    final cur = appBuild(package.buildNumber);

    if (hasReleaseRepo && shouldShowWhatsNew(cur, settings.lastSeenBuild)) {
      final notes = await service.notesForTag('v${package.version}+$cur');
      if (notes != null && notes.isNotEmpty) {
        await _show(
          UpdateInfo(
            version: package.version,
            build: cur,
            apkUrl: '',
            sha256: '',
            notes: notes,
          ),
          readOnly: true,
        );
      }
    }
    if (settings.lastSeenBuild != cur) await settings.setLastSeenBuild(cur);

    if (!hasReleaseRepo || !settings.autoCheckUpdates) return;
    final since =
        DateTime.now().millisecondsSinceEpoch - settings.lastUpdateCheckMs;
    if (since < recheckAfter.inMilliseconds) return;
    try {
      final info = await service.checkLatest();
      await settings.setLastUpdateCheckMs(
        DateTime.now().millisecondsSinceEpoch,
      );
      if (shouldShowUpdateAlert(info, cur, settings.dismissedUpdateBuild)) {
        await _show(info!);
      }
    } catch (_) {
      // Offline or GitHub down: try again next launch.
    }
  }

  /// Shows the dialog; any way of closing it counts as "seen" for that build.
  Future<void> _show(UpdateInfo info, {bool readOnly = false}) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    await showDialog<void>(
      context: ctx,
      builder: (_) => UpdateDialog(
        info: info,
        service: service,
        installer: installer,
        readOnly: readOnly,
      ),
    );
    if (!readOnly) await settings.setDismissedUpdateBuild(info.build);
  }
}
