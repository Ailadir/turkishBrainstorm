/// GitHub `owner/repo` that hosts releases and `packs/index.json`.
/// Leave empty until the repo exists; the app then hides update/download
/// features instead of failing.
const String kReleaseRepo = '';

/// Raw URL of the pack index, derived from [kReleaseRepo].
String defaultPackIndexUrl() => kReleaseRepo.isEmpty
    ? ''
    : 'https://raw.githubusercontent.com/$kReleaseRepo/main/packs/index.json';

/// True once a release repo is configured; update checks are skipped otherwise.
bool get hasReleaseRepo => kReleaseRepo.isNotEmpty;
