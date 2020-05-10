import Foundation
import TensorFlow
import XCTest

import SwiftFusion

class JacobianTests: XCTestCase {
  static var allTests = [
    ("testJacobian2D", testJacobian2D),
    ("testMyJacobian1", testMyJacobian1),
    ("testMyJacobian2", testMyJacobian2),
  ]

  func testMyJacobian1() {
    let P = Vector3(3.5,-8.2,4.2)
    let R = Rot3.fromTangent(Vector3(0.3, 0, 0))
    let t12 = Vector6(Tensor<Double>(repeating: 0.1, shape: [6]))
    let t1 = Pose3(R, P)
    let t2 = Pose3(coordinate: t1.coordinate.global(t12))
    let prior_factor = PriorFactor(0, t1)
    var vals = Values()
    vals.insert(0, AnyDifferentiable(t1)) // should be identity matrix,
    // but is not (upper left is zero)
    // Change this to t2, still zero in upper left block

    print(prior_factor.linearize(vals))
  }

  func testMyJacobian2() {
    let zero = Pose3(Rot3(), Vector3(0, 0, 0))
    func f(_ v: Pose3Coordinate) -> Vector6 {
      return zero.coordinate.local(v)
    }
    print(jacobian(of: f, at: zero.coordinate))
  }

  /// tests the Jacobian of a 2D function
  func testJacobian2D() {
    let p1 = Vector2(0, 1), p2 = Vector2(0,0), p3 = Vector2(0,0);
    let pts: [Vector2] = [p1, p2, p3]

    // TODO(fan): Find a better way to do this
    // If we remove the type we will have:
    // a '@differentiable' function can only be formed from
    // a reference to a 'func' or a literal closure
    let f: @differentiable(_ pts: [Vector2]) -> Vector2 = { (_ pts: [Vector2]) -> Vector2 in
      let d = pts[1] - pts[0]

      return d
    }

    let j = jacobian(of: f, at: pts)
    
    // print("j(f) = \(j as AnyObject)")

    // print("Vector2.basisVectors() = \(Vector2.basisVectors() as AnyObject)")
    
    /* Example output:
      J(f) = [
      [ [-1.0, 0.0],
        [1.0, 0.0],
        [0.0, 0.0] ]
      [ [0.0, -1.0],
        [0.0, 1.0],
        [0.0, 0.0] ]
      ]
     So this is 2x3 but the data type is Vector2.
     In "normal" Jacobian notation, we should have a 2x6.
     [ [-1.0, 0.0, 1.0, 0.0, 0.0, 0.0]
       [0.0, -1.0, 0.0, 1.0, 0.0, 0.0] ]
    */
    
    let expected: [Array<Vector2>.TangentVector] = [
        [Vector2(-1.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 0.0)],
        [Vector2(0.0, -1.0), Vector2(0.0, 1.0), Vector2(0.0, 0.0)]
    ]
    /*
    print("J_f(p) = [")
    for c in j {
      print("[")
      for r in c {
        print(r.recursivelyAllKeyPaths(to:Double.self).map {r[keyPath: $0]})
        print(",")
      }
      print("]")
    }
    print("]")
    */
    XCTAssertEqual(expected, j)
  }
}
