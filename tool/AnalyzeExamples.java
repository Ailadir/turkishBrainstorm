import java.nio.file.*;
import java.util.*;
import zemberek.morphology.TurkishMorphology;

/**
 * Checks grammar-pack examples: prints "FAIL id word" when no analysis of the
 * word contains the declared suffix id. Input lines: id \t word.
 */
public class AnalyzeExamples {
  public static void main(String[] a) throws Exception {
    TurkishMorphology m = TurkishMorphology.createWithDefaults();
    int bad = 0;
    for (String line : Files.readAllLines(Paths.get(a[0]))) {
      String[] p = line.split("\t");
      if (p.length != 2) continue;
      boolean ok = false;
      for (var s : m.analyze(p[1].toLowerCase(new Locale("tr"))).getAnalysisResults()) {
        for (var mo : s.getMorphemes()) if (mo.id.equals(p[0])) ok = true;
      }
      if (!ok) { System.out.println("FAIL " + p[0] + " " + p[1]); bad++; }
    }
    System.exit(bad == 0 ? 0 : 1);
  }
}
