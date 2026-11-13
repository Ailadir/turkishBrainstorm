import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../data/pack_repository.dart';
import '../domain/pack.dart';
import 'settings_service.dart';

const bundledStarterPacks = [
  'assets/packs/tr-a1-essentials.json',
  'assets/packs/tr-a1-core.json',
  'assets/packs/tr-grammar-a1.json',
];

class PackService {
  final PackRepository repo;
  final SettingsService settings;
  final http.Client _http;
  final Future<String> Function(String assetPath) _loadAsset;

  PackService(
    this.repo,
    this.settings, {
    http.Client? client,
    Future<String> Function(String)? loadAsset,
  }) : _http = client ?? http.Client(),
       _loadAsset = loadAsset ?? rootBundle.loadString;

  String get _indexUrl => settings.packIndexUrl;
  bool get hasRemote => _indexUrl.isNotEmpty;

  /// Index entries; throws on network errors (the screen shows "offline").
  Future<List<PackIndexEntry>> fetchIndex() async {
    if (!hasRemote) return const [];
    final r = await _http
        .get(Uri.parse(_indexUrl))
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) {
      throw PackFormatException('Index: HTTP ${r.statusCode}');
    }
    return parsePackIndex(utf8.decode(r.bodyBytes));
  }

  /// Downloads, verifies the sha256 and imports one pack.
  Future<({int added, int updated})> download(PackIndexEntry e) async {
    final base = _indexUrl.substring(0, _indexUrl.lastIndexOf('/') + 1);
    final r = await _http
        .get(Uri.parse('$base${e.file}'))
        .timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) {
      throw PackFormatException('${e.file}: HTTP ${r.statusCode}');
    }
    if (sha256.convert(r.bodyBytes).toString() != e.sha256) {
      throw PackFormatException('Checksum mismatch for ${e.file}');
    }
    return repo.import(parsePack(utf8.decode(r.bodyBytes)));
  }

  /// System file picker, then parse + import. Returns null if cancelled.
  Future<Pack?> importFromFile() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final pack = parsePack(utf8.decode(bytes));
    await repo.import(pack);
    return pack;
  }

  /// One tap on Home: essentials + A1 core + A1 suffix examples.
  Future<int> installStarter() async {
    var words = 0;
    for (final path in bundledStarterPacks) {
      final pack = parsePack(await _loadAsset(path));
      final r = await repo.import(pack);
      words += r.added;
    }
    return words;
  }

  Future<bool> starterInstalled() async =>
      await repo.installedVersion('tr-a1-core') != null;
}
