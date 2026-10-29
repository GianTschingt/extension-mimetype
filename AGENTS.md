# MimeType Extension — Agent Guide

Maven-based Lucee extension that replaces Lucee's built-in mime type detection (file extension map and magic bytes) with Apache Tika (tika-core only). It implements the `lucee.runtime.util.MimeTypeDetector` interface of the Lucee loader and is registered through the `mimetype` attribute in the extension manifest.

## Folder Structure

- `source/java/src/` — Java source
- `source/java/pom.xml` — module POM (the library dependencies, bundled into the extension)
- `pom.xml` — root Maven build, extension manifest values, `.lex` packaging
- `build.xml` — Ant part of the build, writes the extension `MANIFEST.MF` (called from Maven)
- `tests/` — CFML integration tests (label: `mimetype`)
- `CHANGELOG.md` — release notes, update for user-visible changes

## Build

Requires JDK 21 (the Lucee 9 jar has Java 21 class files, javac cannot read them with an older JDK) and Maven. The Lucee dependency (`org.lucee:lucee`, scope provided) must be available in the local Maven repository for the version in `source/java/pom.xml`.

```bash
mvn clean install -Dgoal=install
```

Output: `target/*.lex`

Versions and releases are handled by the GitHub workflow, which passes `-Drevision` (see "Versioning and releases" in `README.md`). A manual deploy by maintainers uses a local `maven-deploy.sh` (not committed, it is in the global gitignore), which needs `MAVEN_USERNAME`, `MAVEN_PASSWORD` and `GPG_PASSPHRASE` in the environment. Never commit credentials.

## Test

CI (`.github/workflows/main.yml`) builds once and runs the tests with [script-runner](https://github.com/lucee/script-runner) against the Lucee versions defined in the repository variable `LUCEE_TEST_VERSIONS_9`.

## Notes

- Minimum Lucee version is `9.0.0.4-ALPHA` (`luceeCoreVersion` in `pom.xml`).
- The manifest attribute is `mimetype`; it is written in `build.xml` (`createManifest`).
- Behaviour must stay compatible with the built-in detector in Lucee (`lucee.commons.io.MimeTypeDetectorImpl`), which is also used as the fallback inside the Tika detector for tika specific types.
