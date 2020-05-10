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

/// A dictionary of type-erased differentiable values.
///
/// Is differentiable, with tangent values represented as sparse `BlockVector`s, so that we can
/// efficiently represent derivatives of functions that access few elements.
public struct Values: Differentiable & KeyPathIterable {

  /// MARK: - Storage for the dictionary of values.

  /// The differentiable values.
  private var values: [AnyDifferentiable] = []

  /// Dictionary from keys to their corresponding index in `values`.
  @noDerivative private var valueIndices: [Int: Int] = [:]

  /// MARK: - Differentiable conformance and related properties and helpers.

  /// The product space of the tangent spaces of `values`, represented as a sparse `BlockVector`.
  ///
  /// If the dimensions of the tangent spaces of `values` are `n0`, `n1`, etc, then:
  /// - The first `n0` components of the `BlockVector` are the components of the tangent space of
  ///   `values[0]`.
  /// - The next `n1` components of the `BlockVector` are the components of the tangent space of
  ///   `values[1]`.
  /// - etc.
  public typealias TangentVector = BlockVector

  /// Dimension of the tangent space.
  ///
  /// This is `n0 + n1 + ...`, where `n0`, `n1`, etc are defined in the `TangentVector` comment.
  @noDerivative public private(set) var tangentDimension: Int = 0

  /// `tangentOffsets[i]` is the offset of the tangent space of `values[i]` within `Values`'
  /// tangent space.
  ///
  /// The elements are:
  /// - 0,
  /// - n0,
  /// - n0 + n1,
  /// - etc,
  /// where `n0`, `n1`, etc are defined in the `TangentVector` comment.
  @noDerivative private var tangentOffsets: [Int] = []

  /// The indices of the tangent subspace corresponding to `values[valueIndex]`.
  private func tangentIndices(_ valueIndex: Int) -> Range<Int> {
    let startIndex = tangentOffsets[valueIndex]
    let endIndex: Int
    if valueIndex < tangentOffsets.count - 1 {
      endIndex = tangentOffsets[valueIndex + 1]
    } else {
      endIndex = tangentDimension
    }
    return startIndex..<endIndex
  }

  /// `makeTangentVector[i]` produces a type-erased tangent vector for `values[i]`.
  private var makeTangentVector: [(ArraySlice<Double>) -> AnyDerivative] = []

  /// Moves `self` along the given `direction`.
  ///
  /// Precondition: `direction` is represented as a single block spanning the entire tangent space.
  /// TODO: We can lift the precondition by handling all the other cases in the implementation.
  public mutating func move(along direction: BlockVector) {
    precondition(direction.blockIndices.count == 1)
    precondition(direction.blockIndices.startIndex == 0)
    precondition(direction.blockIndices.endIndex == tangentDimension)

    for valueIndex in values.indices {
      let tangentVector =
        makeTangentVector[valueIndex](direction.scalars[tangentIndices(valueIndex)])
      values[valueIndex].move(along: tangentVector)
    }
  }

  // MARK: - Subscript and its derivative.

  /// Access the value at `key`, with type `type`.
  ///
  /// Precondition: The value actually has type `type`.
  @differentiable
  public subscript<T: Differentiable>(key: Int, as type: T.Type) -> T
    where T.TangentVector: FixedDimensionVector
  {
    get {
      return values[valueIndices[key]!].baseAs(type)
    }
    set(newValue) {
      values[valueIndices[key]!] = AnyDifferentiable(newValue)
    }
  }

  @derivative(of: subscript)
  @usableFromInline
  func vjpSubscript<T: Differentiable>(key: Int, as type: T.Type)
    -> (value: T, pullback: (T.TangentVector) -> BlockVector)
    where T.TangentVector: FixedDimensionVector
  {
    let valueIndex = valueIndices[key]!
    let indices = tangentIndices(valueIndex)
    return (
      values[valueIndex].baseAs(type),
      // This pullback maps `t: T.TangentVector` to `(0, ..., 0, t0, ..., tn, 0, ..., 0)`.
      { t in BlockVector(t.scalars, indices: indices) }
    )
  }

  // MARK: - Initialization and insertion.

  /// Creates an empty `Values`.
  public init() {}

  /// Inserts `value` at `key`.
  public mutating func insert<T: Differentiable>(_ key: Int, _ value: T) where T.TangentVector: FixedDimensionVector {
    precondition(valueIndices[key] == nil)
    self.valueIndices[key] = self.values.count
    self.values.append(AnyDifferentiable(value))
    self.makeTangentVector.append({ block in AnyDerivative(T.TangentVector(block)) })
    self.tangentOffsets.append(tangentDimension)
    tangentDimension += T.TangentVector.dimension
    checkInvariants()
  }

  /// MARK: - Public convenience properties.

  /// The keys.
  public var keys: Dictionary<Int, Int>.Keys {
    get {
      valueIndices.keys
    }
  }

  /// The count of variables.
  public var count: Int {
    return values.count
  }

  // MARK: - Private helpers.

  /// Asserts that invariants hold.
  ///
  /// Note that this is `O(n)` in the number of values, so checking invariants in a loop that
  /// inserts `n` values is `O(n^2)`. This is okay because assertions are disabled in optimized
  /// builds.
  private func checkInvariants() {
    assert(values.count == makeTangentVector.count)
    assert(values.count == valueIndices.count)
    assert(values.count == tangentOffsets.count)
    for i in valueIndices.values {
      assert(values.indices.contains(i))
    }
    for i in tangentOffsets.indices {
      if i < tangentOffsets.count - 1 {
        assert(tangentOffsets[i] < tangentOffsets[i + 1])
      } else {
        assert(tangentOffsets[i] < tangentDimension)
      }
    }
  }
}

extension Values: CustomStringConvertible {
  public var description: String {
    // Maps value indices to keys. This is the reverse of the `valueIndices` dictionary.
    var keys: [Int: Int] = [:]
    for (key, value) in valueIndices {
      keys[value] = key
    }

    var description: String = "Values(\n"
    for (valueIndex, value) in values.enumerated() {
      description += "  \(keys[valueIndex]!) -> \(value.base)\n"
    }
    description += ")"
    return description
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
