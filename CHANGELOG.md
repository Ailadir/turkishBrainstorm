# Changelog

Add a section at the top for every release: `## <version>+<build>` matching
`version:` in pubspec.yaml, then `- ` bullet lines. The release workflow fails
if the section is missing.

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
