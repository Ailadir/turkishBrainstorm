import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config.dart';

class UpdateException implements Exception {
  final String message;
  UpdateException(this.message);
  @override
  String toString() => message;
}

class UpdateInfo {
  final String version;
  final int build;
  final String apkUrl;
  final String sha256;
  final String notes;
  final String? published;
  const UpdateInfo({
    required this.version,
    required this.build,
    required this.apkUrl,
    required this.sha256,
    required this.notes,
    this.published,
  });
}

/// Show the "new version" alert once per release.
bool shouldShowUpdateAlert(
  UpdateInfo? info,
  int currentBuild,
  int dismissedBuild,
) => info != null && info.build > currentBuild && info.build != dismissedBuild;

/// Show "What's new" once after an update (not on a fresh install).
bool shouldShowWhatsNew(int currentBuild, int lastSeenBuild) =>
    lastSeenBuild != 0 && currentBuild > lastSeenBuild;

/// The Kotlin side of installing an APK (`app_update` channel).
class AppInstaller {
  static const _channel = MethodChannel('app_update');
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;
  Future<void> openInstallPermission() =>
      _channel.invokeMethod('openInstallPermission');
  Future<void> installApk(String path) =>
      _channel.invokeMethod('installApk', {'path': path});
}

/// Build number as written in pubspec. `flutter build --split-per-abi` adds
/// 1000 (armv7), 2000 (arm64) or 4000 (x86_64) to the installed versionCode,
/// so the phone reports 2002 for build 2.
int appBuild(String reported) => (int.tryParse(reported) ?? 0) % 1000;

/// Checks GitHub Releases for a newer build and installs it.
class UpdateService {
  final String repo;
  final http.Client _http;
  final Future<int> Function() currentBuild;
  final Future<Directory> Function() cacheDir;

  UpdateService({
    String? repo,
    http.Client? client,
    Future<int> Function()? currentBuild,
    Future<Directory> Function()? cacheDir,
  }) : repo = repo ?? kReleaseRepo,
       _http = client ?? http.Client(),
       currentBuild = currentBuild ?? _packageBuild,
       cacheDir = cacheDir ?? _defaultCacheDir;

  static Future<int> _packageBuild() async =>
      appBuild((await PackageInfo.fromPlatform()).buildNumber);

  static Future<Directory> _defaultCacheDir() async {
    final base = await getTemporaryDirectory();
    final d = Directory(p.join(base.path, 'updates'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static const _headers = {
    'Accept': 'application/vnd.github+json',
    // A generic name: no personal data goes to GitHub.
    'User-Agent': 'turkish-vocab-app',
  };

  Future<Map<String, dynamic>> _getJson(String url) async {
    final r = await _http
        .get(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) {
      throw UpdateException('GitHub answered HTTP ${r.statusCode}');
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  /// The latest release if it is newer than this build, else null.
  /// Throws [UpdateException] on network/HTTP errors.
  Future<UpdateInfo?> checkLatest() async {
    final info = await latestRelease();
    if (info == null) return null;
    return info.build > await currentBuild() ? info : null;
  }

  /// The latest published release (whatever its build), or null if it has no
  /// `version.json` (e.g. a manual release).
  Future<UpdateInfo?> latestRelease() async {
    try {
      return await _fromRelease(
        await _getJson('https://api.github.com/repos/$repo/releases/latest'),
      );
    } on UpdateException {
      rethrow;
    } catch (e) {
      throw UpdateException('Could not check for updates: $e');
    }
  }

  /// Notes of the release for [tag] (e.g. `v1.1.0+2`), or null.
  Future<String?> notesForTag(String tag) async {
    try {
      final info = await _fromRelease(
        await _getJson(
          'https://api.github.com/repos/$repo/releases/tags/${Uri.encodeComponent(tag)}',
        ),
      );
      return info?.notes;
    } catch (_) {
      return null;
    }
  }

  Future<UpdateInfo?> _fromRelease(Map<String, dynamic> release) async {
    final assets = (release['assets'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final meta = assets.where((a) => a['name'] == 'version.json').firstOrNull;
    if (meta == null) return null;
    final r = await _http
        .get(
          Uri.parse(meta['browser_download_url'] as String),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final apk = assets.where((a) => a['name'] == j['apk']).firstOrNull;
    if (apk == null) return null;
    return UpdateInfo(
      version: j['version'] as String,
      build: (j['build'] as num).toInt(),
      apkUrl: apk['browser_download_url'] as String,
      sha256: (j['sha256'] as String).toLowerCase(),
      notes: (j['notes'] as String? ?? '').trim(),
      published: j['published'] as String?,
    );
  }

  /// Downloads the APK and verifies its SHA-256. On a mismatch the file is
  /// deleted and [UpdateException] is thrown. Returns the file path.
  Future<String> download(
    UpdateInfo info, {
    void Function(double fraction)? onProgress,
  }) async {
    final dir = await cacheDir();
    final file = File(p.join(dir.path, 'update.apk'));
    if (await file.exists()) await file.delete();
    final resp = await _http.send(http.Request('GET', Uri.parse(info.apkUrl)));
    if (resp.statusCode != 200) {
      throw UpdateException('Download failed: HTTP ${resp.statusCode}');
    }
    final total = resp.contentLength ?? 0;
    var got = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in resp.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress?.call(got / total);
      }
    } finally {
      await sink.close();
    }
    final digest = (await sha256.bind(file.openRead()).first).toString();
    if (digest != info.sha256) {
      await file.delete();
      throw UpdateException(
        'The downloaded file is damaged (checksum mismatch).',
      );
    }
    return file.path;
  }
}
