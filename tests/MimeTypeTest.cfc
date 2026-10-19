component extends="org.lucee.cfml.test.LuceeTestCase" labels="mimetype" {

	variables.TIKA_DETECTOR = "org.lucee.extension.mimetype.TikaMimeTypeDetector";
	variables.DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
	variables.XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

	function run( testResults, testBox ) {

		describe( "MimeType extension", function() {

			beforeEach( function() {
				variables.dir = getTempDirectory() & "mimetype_" & createUUID() & "/";
				directoryCreate( variables.dir );
			} );

			afterEach( function() {
				if ( directoryExists( variables.dir ) ) directoryDelete( variables.dir, true );
			} );

			it( title="the engine uses the Tika detector once the extension is installed", body=function( currentSpec ) {
				var detector = createObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance().getMimeTypeDetector();
				expect( detector.getClass().getName() ).toBe( variables.TIKA_DETECTOR );
			} );

			it( title="detects a png file by its content, whatever the extension", body=function( currentSpec ) {
				var file = variables.dir & "image.dat";
				fileWrite( file, binaryDecode( "89504E470D0A1A0A0000000D49484452", "hex" ) );
				expect( fileGetMimeType( file ) ).toBe( "image/png" );
			} );

			it( title="detects a pdf file by its content", body=function( currentSpec ) {
				var file = variables.dir & "doc.dat";
				fileWrite( file, charsetDecode( "%PDF-1.4 hello", "utf-8" ) );
				expect( fileGetMimeType( file ) ).toBe( "application/pdf" );
			} );

			it( title="detects binary content passed directly", body=function( currentSpec ) {
				expect( fileGetMimeType( binaryDecode( "89504E470D0A1A0A0000000D49484452", "hex" ) ) ).toBe( "image/png" );
				expect( fileGetMimeType( charsetDecode( "%PDF-1.4 hello", "utf-8" ) ) ).toBe( "application/pdf" );
			} );

			it( title="detects plain text with and without extension", body=function( currentSpec ) {
				fileWrite( variables.dir & "a.txt", "just some plain text" );
				fileWrite( variables.dir & "readme", "just some plain text" );
				expect( fileGetMimeType( variables.dir & "a.txt" ) ).toBe( "text/plain" );
				expect( fileGetMimeType( variables.dir & "readme" ) ).toBe( "text/plain" );
			} );

			it( title="unknown binary content is an octet-stream", body=function( currentSpec ) {
				var file = variables.dir & "data.unknownext";
				fileWrite( file, binaryDecode( "0001020304FFFE", "hex" ) );
				expect( fileGetMimeType( file ) ).toBe( "application/octet-stream" );
			} );

			// the built-in detector of Lucee only knows application/msword and application/vnd.ms-excel here
			it( title="knows the exact type of zip based office formats", body=function( currentSpec ) {
				var file = variables.dir & "report.docx";
				fileWrite( file, binaryDecode( "504B03041400000008000000", "hex" ) );
				expect( fileGetMimeType( file ) ).toBe( variables.DOCX );
			} );

			it( title="detects the exact type of a not existing file by its extension when strict is false", body=function( currentSpec ) {
				expect( fileGetMimeType( file=variables.dir & "nope.xlsx", strict=false ) ).toBe( variables.XLSX );
				expect( fileGetMimeType( file=variables.dir & "nope.png", strict=false ) ).toBe( "image/png" );
			} );

		} );

	}

}
