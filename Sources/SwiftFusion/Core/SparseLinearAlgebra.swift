/// A vector stored as a collection of blocks.
public struct SparseVector {
  /// The indices of the blocks.
  ///
  /// For example, if `blockIndices == [5..<10, 98..<100]`, then the vector has nonzero entries at
  /// components 5, 6, 7, 8, 9, 98, and 99.
  ///
  /// `blockIndices` are allowed to overlap, and overlapping components accumulate by addition.
  @noDerivative fileprivate var blockIndices: [Range<Int>]

  /// The scalars in the blocks.
  ///
  /// The first `blockIndices[0].count` scalars are the scalars for the first block, the next
  /// `blockIndices[1].count` scalars are the scalars for the second block, etc.
  fileprivate var scalars: [Double]
}

/// Initializers.
extension SparseVector {
  /// Create a `SparseVector` with the givien `scalars` and `blockIndices`.
  ///
  /// Precondition: `scalars.count` is the same as the sum of all the `blockIndices` counts.
  fileprivate init(_ scalars: [Double], blockIndices: [Range<Int>]) {
    precondition(scalars.count == blockIndices.map { $0.count }.reduce(0, +))
    self.scalars = scalars
    self.blockIndices = blockIndices
  }

  /// Create a `SparseVector` with components in range `0..<scalars.count` given by `scalars`.
  public init(_ scalars: [Double]) {
    self.scalars = scalars
    self.blockIndices = [scalars.indices]
  }

  /// Create a `SparseVector` with components in range `indices` given by `scalars`.
  ///
  /// Precondition: `scalars` and `indices` have the same count.
  public init(_ scalars: [Double], indices: Range<Int>) {
    precondition(scalars.count == indices.count)
    self.scalars = scalars
    self.blockIndices = [indices]
  }
}

/// Accessors.
extension SparseVector {
  /// The dimension of the vector, determined by the highest index defined in a block.
  public var dimension: Int {
    return blockIndices.map { $0.upperBound }.max() ?? 0
  }

  /// The blocks in this vector.
  ///
  /// Note that `blocks` may overlap, and overlapping components should be intermpreted as
  /// accumulating by addition.
  public var blocks: [Block] {
    var result: [Block] = []
    var offset = 0
    result.reserveCapacity(blockIndices.count)
    for indices in blockIndices {
      result.append(Block(
        scalars[offset..<(offset + indices.count)],
        indices: indices
      ))
      offset += indices.count
    }
    return result
  }

  /// A block of scalars.
  ///
  /// This is a `RandomAccessCollection` that gives you access to the scalars in the block at the
  /// indices where they appear in the `SparseVector`.
  ///
  /// For example, if `block` has scalars [1, 2, 3] at indices [11, 12, 13], then:
  ///   block[10] -> out of bounds
  ///   block[11] == 1
  ///   block[12] == 2
  ///   block[13] == 3
  ///   block[14] -> out of bounds
  ///
  /// Long-term storage of `Block` instances is discouraged. A block holds a reference to the entire
  /// storage of a larger vector, not just to the portion it presents, even after the original
  /// vector's lifetime ends. Long-term storage of a block may therefore prolong the lifetime of
  /// elements that are no longer otherwise accessible, which can appear to be memory leakage.
  public struct Block: RandomAccessCollection {
    public let indices: Range<Int>
    private let scalars: ArraySlice<Double>
    fileprivate init(_ scalars: ArraySlice<Double>, indices: Range<Int>) {
      self.scalars = scalars
      self.indices = indices
    }

    /// Returns a slice with the given `sliceIndices`.
    ///
    /// Precondition: `sliceIndices` is contained in `indices`.
    public subscript(sliceIndices: Range<Int>) -> Block {
      precondition(
        indices.lowerBound <= sliceIndices.lowerBound
          && indices.upperBound >= sliceIndices.upperBound)
      return Block(
        scalars[scalarIndex(sliceIndices.lowerBound)..<scalarIndex(sliceIndices.upperBound)],
        indices: sliceIndices
      )
    }

    /// Returns the index into `scalars` corresponding to `blockIndex`, which is an index into
    /// the block.
    private func scalarIndex(_ blockIndex: Int) -> Int {
      return scalars.startIndex + blockIndex - indices.startIndex
    }

    // MARK: - RandomAccessCollection conformance

    public var startIndex: Int { return indices.lowerBound }
    public var endIndex: Int { return indices.upperBound }

    public func index(after: Int) -> Int { return after + 1 }
    public func index(before: Int) -> Int { return before - 1 }

    public subscript(index: Int) -> Double {
      return scalars[scalarIndex(index)]
    }
  }
}

/// Differentiable conformance.
extension SparseVector: Differentiable {
  public typealias TangentVector = Self
  public func move(along direction: TangentVector) {
    // TODO: implement
    fatalError("unimplemented")
  }
}

extension SparseVector: VectorProtocol {
  public typealias VectorSpaceScalar = Double

  public static func += (_ lhs: inout SparseVector, _ rhs: SparseVector) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static func + (_ lhs: SparseVector, _ rhs: SparseVector) -> SparseVector {
    var result = lhs
    result += rhs
    return result
  }

  public static func -= (_ lhs: inout SparseVector, _ rhs: SparseVector) {
    lhs.scalars.append(contentsOf: rhs.scalars.map { -$0 })
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static func - (_ lhs: SparseVector, _ rhs: SparseVector) -> SparseVector {
    var result = lhs
    result -= rhs
    return result
  }

  public mutating func add(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] += x
    }
  }

  public func adding(_ x: Double) -> SparseVector {
    var result = self
    result.add(x)
    return result
  }

  public mutating func subtract(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] -= x
    }
  }

  public func subtracting(_ x: Double) -> SparseVector {
    var result = self
    result.subtract(x)
    return result
  }

  public mutating func scale(by scalar: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] *= scalar
    }
  }

  public func scaled(by scalar: Double) -> SparseVector {
    var result = self
    result.scale(by: scalar)
    return result
  }

  public static var zero: SparseVector {
    return SparseVector([], blockIndices: [])
  }
}

fileprivate struct MatrixRange {
  let rowRange, columnRange: Range<Int>
}

public struct SparseMatrix {
  fileprivate var scalars: [Double]
  fileprivate var blockIndices: [MatrixRange]

  fileprivate init(_ scalars: [Double], blockIndices: [MatrixRange]) {
    self.scalars = scalars
    self.blockIndices = blockIndices
  }
}

extension SparseMatrix {
  init(rows: [SparseVector]) {
    guard rows.count > 0 else {
      self.init([], blockIndices: [])
      return
    }

    for row in rows {
      if row.blockIndices != rows[0].blockIndices {
        fatalError("non-collatable row case unimplemented")
      }
    }

    var scalars: [Double] = []
    scalars.reserveCapacity(rows.count * rows[0].blockIndices.map { $0.count }.reduce(0, +))
    var blockIndices: [MatrixRange] = []
    blockIndices.reserveCapacity(rows[0].blockIndices.count)
    var rowOffset = 0
    for columnRange in rows[0].blockIndices {
      blockIndices.append(MatrixRange(rowRange: 0..<rows.count, columnRange: columnRange))
      for row in rows {
        scalars.append(contentsOf: row.scalars[rowOffset..<(rowOffset + columnRange.count)])
      }
      rowOffset += columnRange.count
    }
    self.init(scalars, blockIndices: blockIndices)
  }
}

extension SparseMatrix {
  public func offsetting(rowBy offset: Int) -> SparseMatrix {
    return SparseMatrix(
      scalars,
      blockIndices: blockIndices.map { block in
        return MatrixRange(
          rowRange: block.rowRange.offsetting(by: offset),
          columnRange: block.columnRange
        )
      }
    )
  }
}

extension SparseMatrix {
  public static func += (_ lhs: inout SparseMatrix, _ rhs: SparseMatrix) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static var zero: SparseMatrix {
    return SparseMatrix([], blockIndices: [])
  }
}

extension SparseMatrix {
  public static func * (_ lhs: SparseMatrix, _ rhs: Vector) -> Vector {
    let outputDimension = lhs.blockIndices.map { $0.rowRange.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blockIndices {
      for rowIndex in block.rowRange {
        for columnIndex in block.columnRange {
          resultScalars[rowIndex] += lhs.scalars[scalarsIndex] * rhs.scalars[columnIndex]
          scalarsIndex += 1
        }
      }
    }
    return Vector(resultScalars)
  }

  public func dual(_ rhs: Vector) -> Vector {
    let lhs = self
    let outputDimension = lhs.blockIndices.map { $0.columnRange.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blockIndices {
      for rowIndex in block.rowRange {
        for columnIndex in block.columnRange {
          resultScalars[columnIndex] += lhs.scalars[scalarsIndex] * rhs.scalars[rowIndex]
          scalarsIndex += 1
        }
      }
    }
    return Vector(resultScalars)
  }
}

fileprivate extension Range where Bound == Int {
  func offsetting(by offset: Int) -> Range {
    return (lowerBound + offset)..<(upperBound + offset)
  }
}
