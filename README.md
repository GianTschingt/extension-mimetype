# Lucee MimeType Extension

With Lucee 9, the mime type detection based on Apache Tika has moved from the core into this extension.

Lucee has a simple built-in detection (file extension map and the first bytes of the content). When this extension is installed, Lucee uses Apache Tika (tika-core, without the parsers) instead, which recognizes more formats.

The extension is used by everything in Lucee that needs a mime type, for example:

- `fileGetMimeType()`
- file uploads (`lucee.fileupload.allow.mimetype.detection`)
- `cfhttp`, AI parts and other places that check content

Extensions and Lucee code get the active detector with `CFMLEngineFactory.getInstance().getMimeTypeDetector()`.

Issues: https://luceeserver.atlassian.net/browse/LDEV-6638

## Versioning and releases

Works like Lucee core (LDEV-6516): every code change gets its own version number. The version is not edited by hand.
`pom.xml` uses a CI-friendly `${revision}` built from `extension.version.base`, a build number and
`extension.version.qualifier` (`-SNAPSHOT`).

* **Every push to `main`** (a merged PR or a direct commit) takes the highest existing build of the base, from the git tags,
  Maven Central and the Central snapshot repository, adds 1, builds, tests, publishes that version (e.g. `1.0.0.N-SNAPSHOT`)
  to the [Central snapshot repository](https://central.sonatype.com/repository/maven-snapshots/) and creates the tag `1.0.0.N`.
* Pushes run one after another (workflow concurrency queue), so two quick merges get two different numbers.
* PR builds, forks and runs without the deploy secrets build and test `1.0.0.0-SNAPSHOT` and never use up a number.
* **Release candidate or final release:** run the workflow by hand (Actions > Java CI Combined > Run workflow), choose the branch
  `main`, tick `deploy` and pick `RC`, `BETA`, `ALPHA` or `release` as qualifier. That publishes the current code once with the
  next build number (e.g. `1.0.0.N-RC` or `1.0.0.N`) to Maven Central and creates a GitHub release with the `.lex` files,
  without a commit; the pom keeps `-SNAPSHOT`.
* To start a new line change `extension.version.base`.
