/// A vector stored as a collection of blocks.
public struct BlockVector {
  /// The indices of the blocks.
  ///
  /// For example, if `blockIndices == [5..<10, 98..<100]`, then the vector has nonzero entries at
  /// components 5, 6, 7, 8, 9, 98, and 99.
  ///
  /// `blockIndices` are allowed to overlap, and overlapping components accumulate by addition.
  @noDerivative public fileprivate(set) var blockIndices: [Range<Int>]

  /// The scalars in the blocks.
  ///
  /// The first `blockIndices[0].count` scalars are the scalars for the first block, the next
  /// `blockIndices[1].count` scalars are the scalars for the second block, etc.
  public fileprivate(set) var scalars: [Double]
}

/// Initializers.
extension BlockVector {
  /// Create a `BlockVector` with the givien `scalars` and `blockIndices`.
  ///
  /// Precondition: `scalars.count` is the same as the sum of all the `blockIndices` counts.
  fileprivate init(_ scalars: [Double], blockIndices: [Range<Int>]) {
    precondition(scalars.count == blockIndices.map { $0.count }.reduce(0, +))
    self.scalars = scalars
    self.blockIndices = blockIndices
  }

  /// Create a `BlockVector` with components in range `0..<scalars.count` given by `scalars`.
  public init(_ scalars: [Double]) {
    self.scalars = scalars
    self.blockIndices = [scalars.indices]
  }

  /// Create a `BlockVector` with components in range `indices` given by `scalars`.
  ///
  /// Precondition: `scalars` and `indices` have the same count.
  public init(_ scalars: [Double], indices: Range<Int>) {
    precondition(scalars.count == indices.count)
    self.scalars = scalars
    self.blockIndices = [indices]
  }
}

/// Conversion to `Vector`.
extension Vector {
  /// Creates a `Vector` with the same value as `blockVector`.
  public init(_ blockVector: BlockVector) {
    self.scalars = Array(repeating: 0, count: blockVector.dimension)
    var blockVectorScalarIndex = 0
    for block in blockVector.blockIndices {
      for resultVectorScalarIndex in block {
        self.scalars[resultVectorScalarIndex] += blockVector.scalars[blockVectorScalarIndex]
        blockVectorScalarIndex += 1
      }
    }
  }
}

/// Accessors.
extension BlockVector {
  /// The dimension of the vector, determined by the highest index defined in a block.
  public var dimension: Int {
    return blockIndices.map { $0.upperBound }.max() ?? 0
  }
}

extension BlockVector {
  public func offsetting(by offset: Int) -> BlockVector {
    return BlockVector(scalars, blockIndices: blockIndices.map { $0.offsetting(by: offset) })
  }
}

/// Differentiable conformance.
extension BlockVector: Differentiable {
  public typealias TangentVector = Self
  public func move(along direction: TangentVector) {
    // TODO: implement
    fatalError("unimplemented")
  }
}

extension BlockVector: VectorProtocol {
  public typealias VectorSpaceScalar = Double

  public static func += (_ lhs: inout BlockVector, _ rhs: BlockVector) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static func + (_ lhs: BlockVector, _ rhs: BlockVector) -> BlockVector {
    var result = lhs
    result += rhs
    return result
  }

  public static func -= (_ lhs: inout BlockVector, _ rhs: BlockVector) {
    lhs.scalars.append(contentsOf: rhs.scalars.map { -$0 })
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static func - (_ lhs: BlockVector, _ rhs: BlockVector) -> BlockVector {
    var result = lhs
    result -= rhs
    return result
  }

  public mutating func add(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] += x
    }
  }

  public func adding(_ x: Double) -> BlockVector {
    var result = self
    result.add(x)
    return result
  }

  public mutating func subtract(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] -= x
    }
  }

  public func subtracting(_ x: Double) -> BlockVector {
    var result = self
    result.subtract(x)
    return result
  }

  public mutating func scale(by scalar: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] *= scalar
    }
  }

  public func scaled(by scalar: Double) -> BlockVector {
    var result = self
    result.scale(by: scalar)
    return result
  }

  public static var zero: BlockVector {
    return BlockVector([], blockIndices: [])
  }
}

fileprivate extension Range where Bound == Int {
  func offsetting(by offset: Int) -> Range {
    return (lowerBound + offset)..<(upperBound + offset)
  }
}
