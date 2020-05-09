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

/// The class that holds Key-Value pairs.
public struct Values: Differentiable & KeyPathIterable {

  public typealias ScalarType = Double

  /// MARK: - Stored properties

  private var values: [AnyDifferentiable] = []

  /// Dictionary from Key to index
  @noDerivative private var indices: [Int: Int] = [:]

  @noDerivative private var errorDimension: Int = 0
  @noDerivative private var ranges: [Int: Range<Int>] = [:]

  /// MARK: - Differentiable conformance

  public typealias TangentVector = SparseVector

  public mutating func move(along direction: TangentVector) {
    // gonna need some clever casting or constraints here
    fatalError("unimplemented")
  }

  // MARK: - Subscript and its derivative

  @differentiable
  public subscript<T: Differentiable>(key: Int, as type: T.Type) -> T
    where T.TangentVector: FixedDimensionVector
  {
    get {
      return values[indices[key]!].baseAs(type)
    }
    set(newValue) {
      values[indices[key]!] = AnyDifferentiable(newValue)
    }
  }

  @derivative(of: subscript)
  @usableFromInline
  func vjpSubscript<T: Differentiable>(key: Int, as type: T.Type)
    -> (value: T, pullback: (T.TangentVector) -> SparseVector)
    where T.TangentVector: FixedDimensionVector
  {
    let block = ranges[key]!
    return (self[key, as: type], { SparseVector($0.scalars, block: block) })
  }

  // MARK: - Unorganized

  public var keys: Dictionary<Int, Int>.Keys {
    get {
      indices.keys
    }
  }
  /// Default initializer
  public init() { }

  /// Returns the number of variables.
  public var count: Int {
    return values.count
  }
  
  /// Insert a key value pair
  public mutating func insert<T: Differentiable>(_ key: Int, _ value: T) where T.TangentVector: FixedDimensionVector {
    assert(indices[key] == nil)

    let range = errorDimension..<(errorDimension + T.TangentVector.dimension)
    errorDimension += T.TangentVector.dimension

    self.indices[key] = self.values.count
    self.ranges[key] = range
    self.values.append(AnyDifferentiable(value))
  }
  
}

extension Values: CustomStringConvertible {
  public var description: String {
    "TODO"
  }
}

//extension Values: Equatable {
//  /// Order-aware comparison
//  public static func == (lhs: Values, rhs: Values) -> Bool {
//    if lhs._indices.keys != rhs._indices.keys {
//      return false
//    }
//
//    for k in lhs._indices.keys {
//      if lhs._values[lhs._indices[k]!] != rhs._values[rhs._indices[k]!] {
//        return false
//      }
//    }
//
//    return true
//  }
//}
