import java.nio.file.*;
import java.util.*;
import zemberek.morphology.TurkishMorphology;
import zemberek.morphology.analysis.SingleAnalysis;

/**
 * Finds attested inflected forms per suffix id.
 *   java -cp android/app/libs/zemberek-full.jar tool/GrammarMiner.java tr_full.txt 150000 > forms.tsv
 * Reads the first N lines of a "word count" frequency list.
 * Output: suffixId \t word \t lemma \t count (one row per suffix in the first analysis).
 */
public class GrammarMiner {
  public static void main(String[] a) throws Exception {
    TurkishMorphology m = TurkishMorphology.createWithDefaults();
    int limit = Integer.parseInt(a[1]);
    int i = 0;
    for (String line : Files.readAllLines(Paths.get(a[0]))) {
      if (i++ >= limit) break;
      String[] p = line.trim().split("\\s+");
      if (p.length != 2) continue;
      String word = p[0].toLowerCase(new Locale("tr"));
      if (word.length() < 3 || !word.matches("\\p{L}+")) continue;
      var res = m.analyze(word).getAnalysisResults();
      if (res.isEmpty()) continue;
      // Simplest analysis wins (buna = bu+Dat, not bunamak+Imp).
      SingleAnalysis s = res.get(0);
      for (SingleAnalysis c : res) if (c.getMorphemes().size() < s.getMorphemes().size()) s = c;
      if (s.isUnknown() || s.isRuntime()) continue;
      var sec = s.getDictionaryItem().secondaryPos;
      if (sec != null && sec.shortForm.equals("Prop")) continue;
      String lemma = s.getDictionaryItem().lemma;
      var ms = s.getMorphemes();
      for (int k = 1; k < ms.size(); k++) {
        System.out.println(ms.get(k).id + "\t" + word + "\t" + lemma + "\t" + p[1]);
      }
    }
  }
}
