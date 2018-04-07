import XCTest
@testable import BaseProtocolTests
@testable import LanguageServerProtocolTests

XCTMain([

	/*
		Base Protocol Tests
	*/

	/// Types
    // FIXME: these 3 fail because of BaseProtocolTests/Resources/Fixtures.swift @loadFixture
    testCase(HeaderTests.allTests), 
    testCase(RequestIteratorTests.allTests),
    testCase(RequestTests.allTests),

    testCase(ResponseTests.allTests),

	/*
		Language Server Protocol Tests
	*/

	// Extensions
    testCase(URLTests.allTests),
    
    // Functions
    testCase(ConvertTests.allTests),

    // Types
    testCase(CompletionItemTests.allTests),
    testCase(CursorTests.allTests),
    testCase(DidChangeWatchedFilesParamsTests.allTests),
    testCase(LineCollectionTests.allTests),
    testCase(SwiftModuleTests.allTests),
    testCase(SwiftSourceTests.allTests),
    testCase(WorkspaceTests.allTests),
])
