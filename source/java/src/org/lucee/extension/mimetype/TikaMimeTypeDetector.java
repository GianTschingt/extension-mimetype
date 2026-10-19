package org.lucee.extension.mimetype;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.apache.tika.Tika;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.metadata.TikaCoreProperties;

import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.util.MimeTypeDetector;

/**
 * Mime type detection based on Apache Tika (tika-core only, without the parsers). Replaces the
 * simple built-in detection of Lucee (file extension map and magic bytes).
 */
public class TikaMimeTypeDetector implements MimeTypeDetector {

	private static final int MAX_BYTES = 1000;

	// Tika.detect is thread-safe; share a single instance across all callers
	private static final Tika TIKA = new Tika();

	@Override
	public String getMimeType(byte[] barr, String defaultValue) {
		try {
			return TIKA.detect(barr);
		}
		catch (Throwable t) {
			Util.rethrowIfNecessary(t);
			return defaultValue;
		}
	}

	@Override
	public String getMimeType(InputStream is, String defaultValue) {
		try {
			return getMimeType(readMax(is, MAX_BYTES), defaultValue);
		}
		catch (IOException e) {
			return defaultValue;
		}
	}

	@Override
	public String getMimeType(String fileName, String defaultValue) {
		try {
			return TIKA.detect(fileName);
		}
		catch (Exception e) {
			return defaultValue;
		}
	}

	@Override
	public String getMimeType(Resource res, String defaultValue) {
		return getMimeType(res, null, defaultValue);
	}

	@Override
	public String getMimeType(Resource res, String fileName, String defaultValue) {
		CFMLEngine eng = CFMLEngineFactory.getInstance();
		String name = eng.getStringUtil().isEmpty(fileName, true) ? res.getName() : fileName.trim();

		Metadata md = new Metadata();
		md.set(TikaCoreProperties.RESOURCE_NAME_KEY, name);
		md.set(Metadata.CONTENT_LENGTH, Long.toString(res.length()));

		InputStream is = null;
		try {
			String result = TIKA.detect(is = res.getInputStream(), md);
			// tika specific types (for example application/x-tika-ooxml) are replaced by the type of the name
			if (result.indexOf("tika") != -1) {
				String byName = byName(name);
				if (byName != null) return byName;
				if (!eng.getStringUtil().isEmpty(defaultValue)) return defaultValue;
			}
			return result;
		}
		catch (Exception e) {
			String byName = byName(name);
			if (byName != null) return byName;
			return defaultValue;
		}
		finally {
			eng.getIOUtil().closeSilent(is);
		}
	}

	@Override
	public String getMimeType(URL url, String defaultValue) {
		try {
			return TIKA.detect(url);
		}
		catch (Exception e) {
			return defaultValue;
		}
	}

	// the type tika finds by looking at the name only, null if it is unknown
	private static String byName(String name) {
		String type = TIKA.detect(name);
		if (type == null || type.indexOf("tika") != -1 || "application/octet-stream".equals(type)) return null;
		return type;
	}

	private static byte[] readMax(InputStream is, int max) throws IOException {
		byte[] buffer = new byte[max];
		int total = 0;
		int read;
		while (total < max && (read = is.read(buffer, total, max - total)) != -1) {
			total += read;
		}
		if (total == max) return buffer;
		byte[] result = new byte[total];
		System.arraycopy(buffer, 0, result, 0, total);
		return result;
	}
}
