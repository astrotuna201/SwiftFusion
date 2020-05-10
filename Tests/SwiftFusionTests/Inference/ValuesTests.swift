import SwiftFusion
import XCTest

final class ValuesTests: XCTestCase {
  /// Test insertion of values.
  func testInsert() {
    var v = Values()
    v.insert(5, Vector2(1, 2))
    v.insert(6, Pose2(Rot2(3), Vector2(4, 5)))

    /// 2 (Vector2) + 3 (Pose2) == 5
    XCTAssertEqual(v.tangentDimension, 5)

    XCTAssertEqual(v[5, as: Vector2.self], Vector2(1, 2))
    XCTAssertEqual(v[6, as: Pose2.self], Pose2(Rot2(3), Vector2(4, 5)))
  }

  /// Test taking a derivative with respect to `Values`.
  func testDerivative() {
    var v = Values()
    v.insert(0, Vector2(0, 0))
    v.insert(1, Vector2(0, 0))
    v.insert(2, Vector2(0, 0))

    func f(_ v: Values) -> Vector2 {
      return v[1, as: Vector2.self] - v[2, as: Vector2.self]
    }

    let expected = BlockMatrix([
      [0, 0, 1, 0, -1, 0],
      [0, 0, 0, 1, 0, -1]
    ])

    XCTAssertEqual(valueWithJacobian(of: f, at: v).jacobian.tensor, expected.tensor)
  }

  /// Test moving `Values` along a tangent vector.
  func testMove() {

  }

  static var allTests = [
    ("testInsert", testInsert),
    ("testDerivative", testDerivative),
    ("testMove", testMove),
  ]
}
