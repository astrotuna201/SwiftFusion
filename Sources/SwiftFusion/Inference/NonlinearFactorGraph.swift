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
import TensorFlow

/// A factor graph for nonlinear problems
/// TODO(fan): Add noise model
public struct NonlinearFactorGraph {
  public typealias KeysType = Array<Int>
  
  public typealias FactorsType = Array<NonlinearFactor>
  
  public var keys: KeysType = []
  public var factors: FactorsType = []
  
  /// Default initializer
  public init() { }
  
  /// Convenience operator for adding factor
  public static func += (lhs: inout Self, rhs: NonlinearFactor) {
    lhs.factors.append(rhs)
  }

  public func linearization(_ values: Values) -> (linearMap: SparseMatrix, bias: Vector) {
    // TODO: Reserve capacity.
    var linearMap = SparseMatrix.zero
    var bias = Vector.zero
    var rowOffset = 0
    for factor in factors {
      let (factorLinearMap, factorBias) = factor.linearization(values)
      linearMap += factorLinearMap.offsetting(rowBy: rowOffset)
      bias.scalars.append(contentsOf: factorBias.scalars)
      rowOffset += factorBias.scalars.count
    }
    return (linearMap: linearMap, bias: bias)
  }

  /// Returns the total error at `values`.
  public func error(_ values: Values) -> Double {
    return factors.map { $0.error(values) }.reduce(0, +)
  }
}
