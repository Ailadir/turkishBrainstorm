/// Static English glosses for Zemberek morpheme ids (verified against the
/// bundled zemberek-full jar, `TurkishMorphotactics`). Free, offline and
/// deterministic: no AI is needed to explain a suffix.
library;

const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2'];

const List<String> suffixCategories = [
  'case',
  'possessive',
  'plural',
  'person',
  'tense',
  'mood',
  'voice',
  'negation',
  'participle',
  'converb',
  'derivation',
  'copula',
  'question',
];

class SuffixInfo {
  /// Short label shown under a chip, e.g. "plural".
  final String label;

  /// Longer explanation, e.g. "plural: more than one".
  final String gloss;
  final String category;

  /// Approximate CEFR level at which the suffix is usually taught.
  final String level;
  const SuffixInfo(this.label, this.gloss, this.category, this.level);
}

const Map<String, SuffixInfo> suffixGlosses = {
  // ── Plural ──
  'A3pl': SuffixInfo(
    'plural',
    'plural: more than one (-ler/-lar)',
    'plural',
    'A1',
  ),
  // ── Person (verbs / copula) ──
  'A1sg': SuffixInfo('I', 'I (-im/-um/-m)', 'person', 'A1'),
  'A2sg': SuffixInfo('you', 'you, singular (-sin)', 'person', 'A1'),
  'A3sg': SuffixInfo('he/she/it', 'he/she/it (no ending)', 'person', 'A1'),
  'A1pl': SuffixInfo('we', 'we (-iz/-k)', 'person', 'A1'),
  'A2pl': SuffixInfo(
    'you (pl.)',
    'you, plural or polite (-siniz)',
    'person',
    'A1',
  ),
  // ── Possessive ──
  'P1sg': SuffixInfo('my', 'my (-im/-um)', 'possessive', 'A1'),
  'P2sg': SuffixInfo('your', 'your, singular (-in)', 'possessive', 'A1'),
  'P3sg': SuffixInfo('his/her', 'his/her/its (-i/-si)', 'possessive', 'A1'),
  'P1pl': SuffixInfo('our', 'our (-imiz)', 'possessive', 'A1'),
  'P2pl': SuffixInfo('your (pl.)', 'your, plural (-iniz)', 'possessive', 'A1'),
  'P3pl': SuffixInfo('their', 'their (-leri)', 'possessive', 'A1'),
  // ── Case ──
  'Loc': SuffixInfo('in/at', 'in, at, on (-de/-da)', 'case', 'A1'),
  'Dat': SuffixInfo('to', 'to, towards (-e/-a)', 'case', 'A1'),
  'Abl': SuffixInfo('from', 'from, out of (-den/-dan)', 'case', 'A1'),
  'Acc': SuffixInfo('(object)', 'definite object marker (-i/-ı)', 'case', 'A1'),
  'Gen': SuffixInfo("'s", 'of, possessor (-in/-ın)', 'case', 'A1'),
  'Ins': SuffixInfo('with', 'with, by means of (-le/-la)', 'case', 'A2'),
  'Equ': SuffixInfo('as…as', 'as, like, up to (-ce/-ca)', 'case', 'B1'),
  // ── Tense / aspect ──
  'Prog1': SuffixInfo('-ing', 'doing now (-iyor)', 'tense', 'A1'),
  'Past': SuffixInfo('did', 'past tense (-di)', 'tense', 'A1'),
  'Fut': SuffixInfo('will', 'future (-ecek/-acak)', 'tense', 'A2'),
  'Aor': SuffixInfo('usually', 'habitual / general (-ir/-er)', 'tense', 'A2'),
  'Narr': SuffixInfo(
    'apparently',
    'reported / evidential past (-miş)',
    'tense',
    'A2',
  ),
  'Prog2': SuffixInfo('is doing', 'ongoing, formal (-mekte)', 'tense', 'B2'),
  // ── Mood ──
  'Imp': SuffixInfo('command', 'imperative (do it!)', 'mood', 'A1'),
  'Opt': SuffixInfo(
    'let me',
    'optative: let me / let us (-eyim, -elim)',
    'mood',
    'A2',
  ),
  'Neces': SuffixInfo('must', 'must, should (-meli)', 'mood', 'A2'),
  'Cond': SuffixInfo('if', 'conditional (-se)', 'mood', 'B1'),
  'Desr': SuffixInfo('wish', 'wish, desire (-se, wishing)', 'mood', 'B1'),
  'Able': SuffixInfo('can', 'ability: can (-ebil)', 'mood', 'A2'),
  'Unable': SuffixInfo('cannot', 'inability: cannot (-ememek)', 'mood', 'B2'),
  // ── Negation / question / copula ──
  'Neg': SuffixInfo('not', 'negation (-me/-ma)', 'negation', 'A1'),
  'Ques': SuffixInfo('?', 'question particle (mi)', 'question', 'A1'),
  'Cop': SuffixInfo('is', 'copula: is/are (-dir, -im, -sin…)', 'copula', 'A1'),
  // ── Voice ──
  'Pass': SuffixInfo('is done', 'passive (-il, -in)', 'voice', 'B1'),
  'Caus': SuffixInfo(
    'make do',
    'causative: make/let someone do (-dir, -t)',
    'voice',
    'B1',
  ),
  'Reflex': SuffixInfo('oneself', 'reflexive (-in)', 'voice', 'B2'),
  'Recip': SuffixInfo('each other', 'reciprocal (-iş)', 'voice', 'B2'),
  // ── Participles / verbal nouns ──
  'PastPart': SuffixInfo(
    'that did',
    'past participle (-dik)',
    'participle',
    'B1',
  ),
  'FutPart': SuffixInfo(
    'that will',
    'future participle (-ecek)',
    'participle',
    'B1',
  ),
  'PresPart': SuffixInfo(
    '-ing (one)',
    'present participle (-en)',
    'participle',
    'B1',
  ),
  'AorPart': SuffixInfo(
    'habitual one',
    'aorist participle (-ir/-er)',
    'participle',
    'B2',
  ),
  'NarrPart': SuffixInfo(
    'having done',
    'narrative participle (-miş)',
    'participle',
    'B2',
  ),
  'Inf1': SuffixInfo('to …', 'infinitive (-mek/-mak)', 'participle', 'A2'),
  'Inf2': SuffixInfo('the act of', 'verbal noun (-me/-ma)', 'participle', 'B1'),
  'Inf3': SuffixInfo('the act of', 'verbal noun (-iş)', 'participle', 'B2'),
  // ── Converbs ──
  'When': SuffixInfo('when', 'when… (-ince)', 'converb', 'B1'),
  'ByDoingSo': SuffixInfo('by doing', 'by doing (-erek)', 'converb', 'B1'),
  'While': SuffixInfo('while', 'while… (-ken)', 'converb', 'B1'),
  'AfterDoingSo': SuffixInfo(
    'after doing',
    'after doing (-ip)',
    'converb',
    'B1',
  ),
  'SinceDoingSo': SuffixInfo('since', 'since doing (-eli)', 'converb', 'B1'),
  // ── Derivation ──
  'With': SuffixInfo('with', 'having, with (-li)', 'derivation', 'A1'),
  'Without': SuffixInfo(
    'without',
    'lacking, without (-siz)',
    'derivation',
    'A1',
  ),
  'Agt': SuffixInfo(
    'person who',
    'person who does/has (-ci)',
    'derivation',
    'A2',
  ),
  'Ness': SuffixInfo('-ness', 'abstract noun (-lik)', 'derivation', 'A2'),
  'Rel': SuffixInfo('of', 'relating to, of (-ki)', 'derivation', 'A2'),
  'Dim': SuffixInfo('little', 'diminutive (-cik)', 'derivation', 'B1'),
  'Become': SuffixInfo('become', 'become (-leş)', 'derivation', 'B1'),
  'Ly': SuffixInfo('-ly', 'adverb-forming (-ce)', 'derivation', 'B2'),
  'AsIf': SuffixInfo('as if', 'as if (-casına)', 'derivation', 'B2'),
  'Related': SuffixInfo('related', 'relating to (-sal)', 'derivation', 'B2'),
};

/// Info for a Zemberek morpheme id. Unknown ids fall back to the id itself,
/// level B2, so nothing ever crashes on an unmapped suffix.
SuffixInfo suffixInfo(String id) =>
    suffixGlosses[id] ?? SuffixInfo(id, id, 'derivation', 'B2');
