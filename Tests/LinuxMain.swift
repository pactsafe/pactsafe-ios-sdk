import XCTest

import PactSafeTests

var tests = [XCTestCaseEntry]()
tests += PactSafeTests.allTests()
XCTMain(tests)
