package com.turkishvocab.turkish_vocab

import java.util.Locale
import zemberek.morphology.TurkishMorphology
import zemberek.morphology.analysis.AnalysisCache
import zemberek.morphology.analysis.SingleAnalysis
import zemberek.morphology.lexicon.RootLexicon

object MorphologyPlugin {

    private val turkish = Locale.forLanguageTag("tr")

    private val morphology: TurkishMorphology by lazy {
        // Android has no Thread.threadLocalRandomProbe, so Zemberek's default
        // Caffeine dynamic cache crashes on init. Build one with it disabled.
        val cache = AnalysisCache.builder()
            .disableDynamicCache()
            .build()
        TurkishMorphology.builder()
            .setLexicon(RootLexicon.getDefault())
            .setCache(cache)
            .build()
    }

    /** Map form of one analysis: lemma, pos, stem, morphemes [{surface, id}]. */
    private fun toMap(best: SingleAnalysis): Map<String, Any> {
        val morphemes = best.morphemeDataList
            .drop(1) // first entry is the stem
            .filter { it.surface.isNotBlank() }
            .map { mapOf<String, Any>("surface" to it.surface, "id" to it.morpheme.id) }
        return mapOf(
            "lemma" to best.dictionaryItem.lemma,
            "pos" to (best.pos?.shortForm ?: ""),
            "stem" to best.stem,
            "morphemes" to morphemes,
        )
    }

    fun analyze(word: String): Map<String, Any>? {
        return try {
            val results = morphology.analyze(word.lowercase(turkish)).analysisResults
            if (results.isEmpty() || results[0].isUnknown) return null
            toMap(results[0])
        } catch (e: Exception) {
            null
        }
    }

    /** Disambiguated analysis of a multi-word input; one map per token. */
    fun analyzeSentence(text: String): List<Map<String, Any>>? {
        return try {
            morphology.analyzeAndDisambiguate(text.lowercase(turkish))
                .bestAnalysis()
                .map { a -> toMap(a) + mapOf<String, Any>("token" to a.surfaceForm()) }
        } catch (e: Exception) {
            null
        }
    }

    /** One entry per input word; null where the word is unknown. */
    fun analyzeBatch(words: List<String>): List<Map<String, Any>?> =
        words.map { analyze(it) }

    fun warmUp() {
        Thread { morphology }.start()
    }
}
