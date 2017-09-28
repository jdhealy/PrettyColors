// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import PrettyColors

extension EqualityTests {
  static var allTests = [
    ("testA", testA),
    ("testB", testB),
    ("testC", testC),
    ("testD", testD),
    ("testE", testE),
  ]
}

extension PrettyColorsTests {
  static var allTests = [
    ("test_basics", test_basics),
    ("test_problem_SingleStyleParameter", test_problem_SingleStyleParameter),
    ("test_problem_TypeInference", test_problem_TypeInference),
    ("testImmutableFilterOrMap", testImmutableFilterOrMap),
    ("testEmptyWrap", testEmptyWrap),
    ("testMulti", testMulti),
    ("testLetWorkflow", testLetWorkflow),
    ("testAppendStyleParameter", testAppendStyleParameter),
    ("testMutableAppend", testMutableAppend),
    ("testSetForeground", testSetForeground),
    ("testSetForegroundToNil", testSetForegroundToNil),
    ("testSetForegroundToParameter", testSetForegroundToParameter),
    ("testTransformForeground", testTransformForeground),
    ("testTransformForeground2", testTransformForeground2),
    ("testTransformForegroundWithVar", testTransformForegroundWithVar),
    ("testTransformForegroundToBright", testTransformForegroundToBright),
    ("testComputedVariableForegroundEquality", testComputedVariableForegroundEquality),
    ("testEightBitForegroundBackgroundDifference", testEightBitForegroundBackgroundDifference),
    ("testNamedForegroundBackgroundDifference", testNamedForegroundBackgroundDifference),
    ("testNamedBrightnessDifference", testNamedBrightnessDifference),
    ("testZapAllStyleParameters", testZapAllStyleParameters),
  ]
}

XCTMain([
  testCase(EqualityTests.allTests),
  testCase(PrettyColorsTests.allTests),
])
