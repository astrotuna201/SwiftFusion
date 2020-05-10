import TensorFlow
import SwiftFusion
import XCTest

/// Asserts that `x` and `y` have the same shape and that their values have absolute difference
/// less than `accuracy`.
func assertEqual<T: TensorFlowFloatingPoint>(
  _ x: Tensor<T>, _ y: Tensor<T>, accuracy: T, file: StaticString = #file, line: UInt = #line
) {
  guard x.shape == y.shape else {
    XCTFail(
      "shape mismatch: \(x.shape) is not equal to \(y.shape)",
      file: file,
      line: line
    )
    return
  }
  XCTAssert(
    abs(x - y).max().scalarized() < accuracy,
    "value mismatch:\n\(x)\nis not equal to\n\(y)\nwith accuracy \(accuracy)",
    file: file,
    line: line
  )
}

/// Asserts that `x` and `y` have absolute difference less than `accuracy`.
func assertAllKeyPathEqual<T: KeyPathIterable>(
  _ x: T, _ y: T, accuracy: Double, file: StaticString = #file, line: UInt = #line
) {
  let _ = x.recursivelyAllKeyPaths(to: Double.self).map {
    XCTAssert(
      abs(x[keyPath: $0] - y[keyPath: $0]) < accuracy,
      "value mismatch:\n\(x)\nis not equal to\n\(y)\nwith accuracy \(accuracy)",
      file: file,
      line: line
    )
  }
}

/// Factor graph with 2 2D factors on 3 2D variables
public final class SimpleGaussianFactorGraph {
  private static let x1Key = 2
  private static let x2Key = 0
  private static let l1Key = 1

  private static let inputDimension = 2
  private static let x1Offset = x1Key * inputDimension
  private static let x2Offset = x2Key * inputDimension
  private static let l1Offset = l1Key * inputDimension

  public static func create() -> GaussianFactorGraph {
    var fg = GaussianFactorGraph()

    let I_2x2 = SparseMatrix([
      [1, 0],
      [0, 1]
    ])
    let I_2x2_x1 = I_2x2.offsetting(columnBy: x1Offset)
    let I_2x2_x2 = I_2x2.offsetting(columnBy: x2Offset)
    let I_2x2_l1 = I_2x2.offsetting(columnBy: l1Offset)

    // linearized prior on x1: c[_x1_]+x1=0 i.e. x1=-c[_x1_]
    fg += GaussianFactorGraph(
      jacobian: 10 * I_2x2_x1,
      bias: (-1) * Vector([1, 1])
    )
    // fg += JacobianFactor([x1], [10 * I_2x2], -1.0 * Vector2_t(1.0, 1.0))
    // odometry between x1 and x2: x2-x1=[0.2;-0.1]
    fg += GaussianFactorGraph(
      jacobian: (10 * I_2x2_x2) + (-10 * I_2x2_x1),
      bias: Vector([2, -1])
    )
    //fg += JacobianFactor([x2, x1], [10 * I_2x2, -10 * I_2x2], Vector2_t(2.0, -1.0))
    // measurement between x1 and l1: l1-x1=[0.0;0.2]
    fg += GaussianFactorGraph(
      jacobian: (5 * I_2x2_l1) + (-5 * I_2x2_x1),
      bias: Vector([0, 1.0])
    )
    // fg += JacobianFactor([l1, x1], [5 * I_2x2, -5 * I_2x2], Vector2_t(0.0, 1.0))
    // measurement between x2 and l1: l1-x2=[-0.2;0.3]
    fg += GaussianFactorGraph(
      jacobian: (-5 * I_2x2_x2) + (5 * I_2x2_l1),
      bias: Vector([-1.0, 1.5])
    )
    //fg += JacobianFactor([x2, l1], [-5 * I_2x2, 5 * I_2x2], Vector2_t(-1.0, 1.5))
    return fg;
  }

  public static func correctDelta() -> Vector {
    var c = SparseVector.zero
    c += SparseVector([-0.1, 0.1]).offsetting(by: l1Offset)
    c += SparseVector([-0.1, -0.1]).offsetting(by: x1Offset)
    c += SparseVector([0.1, -0.2]).offsetting(by: x2Offset)
    return Vector(c)
  }

  public static func zeroDelta() -> Vector {
    var c = SparseVector.zero
    c += SparseVector([0, 0]).offsetting(by: l1Offset)
    c += SparseVector([0, 0]).offsetting(by: x1Offset)
    c += SparseVector([0, 0]).offsetting(by: x2Offset)
    return Vector(c)
  }
}

extension URL {
  /// Creates a URL for the directory containing the caller's source file.
  static func sourceFileDirectory(file: String = #file) -> URL {
    return URL(fileURLWithPath: file).deletingLastPathComponent()
  }
}

/// Returns the jacobian matrix of `f` at the given point.
public func jacobian<A: Differentiable, B: Differentiable>(
  of f: @differentiable (A) -> B,
  at p: A
) -> SparseMatrix where A.TangentVector: FixedDimensionVector, B.TangentVector: FixedDimensionVector {
  // This implementation hijacks `valueWithJacobian` to compute the jacobian. This does type
  // erasure, so it's slower than it has to be, but that's okay because this is just a utility used
  // to test jacobians.
  var values = Values()
  values.insert(0, p)
  return valueWithJacobian(of: { f($0[0, as: A.self]) }, at: values).jacobian
}

