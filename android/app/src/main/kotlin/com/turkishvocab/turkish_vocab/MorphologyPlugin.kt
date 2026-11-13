package com.turkishvocab.turkish_vocab

import java.util.Locale
import zemberek.morphology.TurkishMorphology
import zemberek.morphology.analysis.AnalysisCache
import zemberek.morphology.lexicon.RootLexicon

object MorphologyPlugin {

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

    fun analyze(word: String): Map<String, Any>? {
        return try {
            val analysis = morphology.analyze(word.lowercase(Locale.forLanguageTag("tr")))
            val results = analysis.analysisResults
            if (results.isEmpty()) return null
            val best = results[0]
            val root = best.dictionaryItem.lemma
            val suffixes = best.morphemeDataList
                .drop(1)                       // first entry is the stem
                .map { it.surface }
                .filter { it.isNotBlank() }
            mapOf<String, Any>(
                "root" to root,
                "suffixes" to suffixes,
            )
        } catch (e: Exception) {
            null
        }
    }

    fun warmUp() {
        Thread { morphology }.start()
    }
}
