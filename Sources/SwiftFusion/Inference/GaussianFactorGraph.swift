// Copyright 2019 The SwiftFusion Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// The least-squares problem of finding `x: Vector` that minimizes the norm of `jacobian * x - b`.
public struct GaussianFactorGraph {
  /// Jacobian term of the least-squares problem.
  public var jacobian: SparseMatrix

  /// Bias term of the least-squares problem.
  public var bias: Vector

  /// Creates an empty `GaussianFactorGraph`.
  public init() {
    self.jacobian = SparseMatrix.zero
    self.bias = Vector.zero
  }

  /// Creates a `GaussianFactorGraph` with the given `jacobian` and `bias`.
  public init(jacobian: SparseMatrix, bias: Vector) {
    self.jacobian = jacobian
    self.bias = bias
  }

  /// Accumulates the factors from `rhs` into `lhs`.
  public static func += (_ lhs: inout GaussianFactorGraph, _ rhs: GaussianFactorGraph) {
    lhs.jacobian += rhs.jacobian.offsetting(rowBy: lhs.bias.scalars.count)
    lhs.bias.scalars.append(contentsOf: rhs.bias.scalars)
  }
}
