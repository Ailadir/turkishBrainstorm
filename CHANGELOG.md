# Changelog

Add a section at the top for every release: `## <version>+<build>` matching
`version:` in pubspec.yaml, then `- ` bullet lines. The release workflow fails
if the section is missing.

## 1.1.6+8
- The offline voice pronounces words properly (altı no longer sounds like artı) and no longer cuts off their start

## 1.1.5+7
- New default offline voice: fahrettin (male), clearer than dfki
- Short words like ve and altı are pronounced properly instead of swallowed

## 1.1.4+6
- Short words (ve, ne, bir) sound clearer: the offline voice speaks them slower and no longer clips them
- The offline voice is slowed natively instead of stretched, so it sounds more natural

## 1.1.3+5
- Speech speed setting (Settings → Speech speed); words now play slower by default

## 1.1.2+4
- Fixed the update check: the app always said it was up to date

## 1.1.1+3
- Fixed the offline voice: it installed but played nothing
- The voice download no longer freezes the app while unpacking
- Settings now shows the real reason when a voice can't play
- "Download audio for my words" says so when you have no words of your own yet

## 1.1.0+2
- New Brainstorm and Review sessions, with a result panel after every answer
- Suffix breakdown on cards, and a Suffix drill
- A1–B2 word packs, downloadable or importable from a file
- Offline dictionary and offline Turkish voice
- Three free AI providers with automatic fallback
- Add words from any app: select text, then "Add to Turkish Vocab"
