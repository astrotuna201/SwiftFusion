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

/// A `NonlinearFactor` that returns the difference of value and desired value
///
/// Input is a dictionary of `Key` to `Value` pairs, and the output is the scalar
/// error value
///
/// Interpretation
/// ================
/// `Input`: the input values as key-value pairs
///
public struct PriorFactor<T: LieGroup>: NonlinearFactor
  where T.TangentVector: VectorConvertible, T.TangentVector == T.Coordinate.LocalCoordinate
{
  @noDerivative
  public var keys: Array<Int> = []
  public var difference: T
  public typealias Output = Error
  
  public init (_ key: Int, _ difference: T) {
    keys = [key]
    self.difference = difference
  }
  typealias ScalarType = Double
  
  /// TODO: `Dictionary` still does not conform to `Differentiable`
  /// Tracking issue: https://bugs.swift.org/browse/TF-899
  // typealias Input = Dictionary<UInt, Tensor<ScalarType>>

  /// Returns the `error` of the factor.
  @differentiable(wrt: values)
  public func error(_ values: Values) -> Double {
    let error = difference.localCoordinate(values[keys[0], as: T.self])
    // TODO: It would be faster to call `error.squaredNorm` because then we don't have to pay
    // the cost of a conversion to `Vector`. To do this, we need a protocol
    // with a `squaredNorm` requirement.
    return error.vector.squaredNorm
  }
  
  @differentiable(wrt: values)
  public func errorVector(_ values: Values) -> T.Coordinate.LocalCoordinate {
    let val = values[keys[0], as: T.self]
    let error = difference.localCoordinate(val)
    return error
  }

  public func linearize(_ values: Values) -> JacobianFactor {
    return JacobianFactor(of: self.errorVector, at: values)
  }
}
