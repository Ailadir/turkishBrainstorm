import java.nio.file.*;
import java.util.*;
import zemberek.morphology.TurkishMorphology;
import zemberek.morphology.analysis.SingleAnalysis;

/**
 * Sums subtitle frequency per (lemma, POS).
 *   java -cp android/app/libs/zemberek-full.jar tool/LemmaCounter.java tr_50k.txt > lemmas.tsv
 * Output: lemma \t pos \t count, sorted by count desc. Skips unknowns,
 * punctuation, numbers and proper nouns.
 */
public class LemmaCounter {
  public static void main(String[] a) throws Exception {
    TurkishMorphology m = TurkishMorphology.createWithDefaults();
    Map<String, Long> counts = new HashMap<>();
    for (String line : Files.readAllLines(Paths.get(a[0]))) {
      String[] p = line.trim().split("\\s+");
      if (p.length != 2) continue;
      String word = p[0].toLowerCase(new Locale("tr"));
      long n = Long.parseLong(p[1]);
      List<SingleAnalysis> res = m.analyze(word).getAnalysisResults();
      if (res.isEmpty()) continue;
      // Simplest analysis wins (buna = bu+Dat, not bunamak+Imp).
      SingleAnalysis s = res.get(0);
      for (SingleAnalysis c : res) if (c.getMorphemes().size() < s.getMorphemes().size()) s = c;
      if (s.isUnknown() || s.isRuntime()) continue;
      String pos = s.getPos().shortForm;
      if (pos.equals("Punc") || pos.equals("Num") || pos.equals("Unk")) continue;
      var sec = s.getDictionaryItem().secondaryPos;
      if (sec != null && sec.shortForm.equals("Prop")) continue;
      String lemma = s.getDictionaryItem().lemma;
      counts.merge(lemma + "\t" + pos, n, Long::sum);
    }
    counts.entrySet().stream()
        .sorted((x, y) -> Long.compare(y.getValue(), x.getValue()))
        .forEach(e -> System.out.println(e.getKey() + "\t" + e.getValue()));
  }
}
