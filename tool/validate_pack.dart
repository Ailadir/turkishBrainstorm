// Validates pack files; exits non-zero on any problem.
//   dart run tool/validate_pack.dart packs/*.json
// Grammar packs are also checked with Zemberek (needs `java` and the jar).
import 'dart:io';

import 'package:turkish_vocab/domain/pack.dart';

const jar = 'android/app/libs/zemberek-full.jar';

Future<void> main(List<String> args) async {
  var failed = false;
  for (final path in args.where((a) => !a.endsWith('index.json'))) {
    try {
      final pack = parsePack(File(path).readAsStringSync());
      if (pack.isGrammar) {
        final tmp = File('${Directory.systemTemp.path}/examples_${pack.id}.tsv');
        tmp.writeAsStringSync([
          for (final s in pack.suffixes)
            for (final e in s.examples) '${s.id}\t${e.tr}',
        ].join('\n'));
        final r = await Process.run('java', ['-cp', jar, 'tool/AnalyzeExamples.java', tmp.path]);
        if (r.exitCode != 0) {
          failed = true;
          stdout.writeln('FAIL $path\n${r.stdout}');
          continue;
        }
      }
      stdout.writeln('ok   $path (${pack.count} ${pack.isGrammar ? 'suffixes' : 'words'})');
    } on PackFormatException catch (e) {
      failed = true;
      stdout.writeln('FAIL $path: ${e.message}');
    }
  }
  exit(failed ? 1 : 0);
}
