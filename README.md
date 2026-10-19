# Lucee MimeType Extension

With Lucee 9, the mime type detection based on Apache Tika has moved from the core into this extension.

Lucee has a simple built-in detection (file extension map and the first bytes of the content). When this extension is installed, Lucee uses Apache Tika (tika-core, without the parsers) instead, which recognizes more formats.

The extension is used by everything in Lucee that needs a mime type, for example:

- `fileGetMimeType()`
- file uploads (`lucee.fileupload.allow.mimetype.detection`)
- `cfhttp`, AI parts and other places that check content

Extensions and Lucee code get the active detector with `CFMLEngineFactory.getInstance().getMimeTypeDetector()`.

Issues: https://luceeserver.atlassian.net/browse/LDEV-6638
