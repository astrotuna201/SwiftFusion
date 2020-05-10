import SwiftFusion
import XCTest

final class GaussianFactorGraphTests: XCTestCase {
  /// Test accumulating factors into a gaussian factor graph.
  func testAccumulateFactors() {
    var graph = GaussianFactorGraph()
    let j1 = SparseMatrix([[1, 2], [3, 4]])
    let j2 = SparseMatrix([[5, 6], [7, 8]])
    let b1 = Vector([9, 10])
    let b2 = Vector([11, 11])
    graph += GaussianFactorGraph(jacobian: j1, bias: b1)
    graph += GaussianFactorGraph(jacobian: j2, bias: b2)

    XCTAssertTrue(graph.jacobian.blocksEqual((j1 + j2.offsetting(rowBy: 2))))
    XCTAssertEqual(
      graph.bias,
      Vector([9, 10, 11, 12])
    )
  }
}
