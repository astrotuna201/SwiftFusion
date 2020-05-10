import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [
    testCase(AnyDifferentiableTests.allTests),
    testCase(BlockVectorTests.allTests),
    testCase(DictionaryDifferentiableTests.allTests),
    testCase(G2OReaderTests.allTests),
    testCase(Rot2Tests.allTests),
    testCase(Pose2Tests.allTests),
    testCase(VectorTests.allTests),
    testCase(NonlinearFactorGraphTests.allTests),
    testCase(GaussianFactorGraphTests.allTests),
    testCase(CGLSTests.allTests),
    testCase(ValuesTests.allTests),
  ]
}
#endif
