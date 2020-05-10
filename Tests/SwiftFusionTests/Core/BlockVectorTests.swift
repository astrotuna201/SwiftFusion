import XCTest

import TensorFlow
import SwiftFusion

class BlockVectorTests: XCTestCase {

  /// Test initializers.
  func testInitializers() {
    let v1 = BlockVector([1, 2, 3])
    XCTAssertEqual(v1.blockIndices, [0..<3])
    XCTAssertEqual(v1.scalars, [1, 2, 3])

    let v2 = BlockVector([1, 2, 3], indices: 100..<103)
    XCTAssertEqual(v2.blockIndices, [100..<103])
    XCTAssertEqual(v2.scalars, [1, 2, 3])
  }

  /// Test conversion to vector.
  func testConvertToVector() {
    let v1 = BlockVector([1, 2, 3], indices: 5..<8) + BlockVector([4], indices: 9..<10)
    XCTAssertEqual(Vector(v1), Vector([0, 0, 0, 0, 0, 1, 2, 3, 0, 4]))
  }

  /// Test dimension property.
  func testDimension() {
    let v1 = BlockVector([1, 2, 3])
    XCTAssertEqual(v1.dimension, 3)

    let v2 = BlockVector([1, 2, 3], indices: 100..<103)
    XCTAssertEqual(v2.dimension, 103)

    let v3 = BlockVector([1, 2, 3], indices: 5..<8) + BlockVector([4], indices: 9..<10)
    XCTAssertEqual(v3.dimension, 10)
  }

  /// Test offsetting utility.
  func testOffsetting() {
    let v1 = BlockVector([1, 2, 3]).offsetting(by: 10)
    XCTAssertEqual(v1.blockIndices, [10..<13])
    XCTAssertEqual(v1.scalars, [1, 2, 3])

    let v2 = (BlockVector([1, 2, 3], indices: 5..<8) + BlockVector([4], indices: 9..<10))
      .offsetting(by: 10)
    XCTAssertEqual(v2.blockIndices, [15..<18, 19..<20])
    XCTAssertEqual(v2.scalars, [1, 2, 3, 4])
  }

  /// Test AdditiveArithmetic conformance.
  func testAdditiveArithmetic() {
    let zero = BlockVector.zero
    XCTAssertEqual(Vector(zero), Vector([]))

    let v1 = BlockVector([1, 2, 3])
    let v2 = BlockVector([4, 5, 6, 7])
    XCTAssertEqual(Vector(v1 + v2), Vector([5, 7, 9, 7]))
    XCTAssertEqual(Vector(v1 - v2), Vector([-3, -3, -3, -7]))
  }

  /// Test VectorProtocol conformance.
  func testVectorProtocol() {
    let v1 = BlockVector([1, 2, 3])
    XCTAssertEqual(Vector(v1.adding(1)), Vector([2, 3, 4]))
    XCTAssertEqual(Vector(v1.subtracting(1)), Vector([0, 1, 2]))
    XCTAssertEqual(Vector(v1.scaled(by: 2)), Vector([2, 4, 6]))
  }

  static var allTests = [
    ("testInitializers", testInitializers),
    ("testConvertToVector", testConvertToVector),
    ("testDimension", testDimension),
    ("testOffsetting", testOffsetting),
    ("testAdditiveArithmetic", testAdditiveArithmetic),
    ("testVectorProtocol", testVectorProtocol)
  ]
}
