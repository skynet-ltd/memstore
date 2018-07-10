import XCTest

import memstoreTests

var tests = [XCTestCaseEntry]()
tests += memstoreTests.allTests()
XCTMain(tests)