import TensorFlow

/// A matrix stored as a sparse collection of blocks.
public struct BlockMatrix {
  /// The indices of the blocks.
  ///
  /// For example, if `blockIndices` is:
  ///   [
  ///     BlockMatrixIndices(rowIndices: 5..<10, columnIndices: 5..<10),
  ///     BlockMatrixIndices(rowIndices: 50..<60, columnIndices: 5..<10)
  ///   ]
  /// then the matrix has nonzero entries at the 5x5 block starting at row 5 column 5, and at the
  /// 10x5 block starting at row 50 column 5.
  public fileprivate(set) var blockIndices: [BlockMatrixIndices]

  /// The scalars in the blocks.
  ///
  /// The first `blockIndices[0].count` scalars are the scalars for the first block in row major
  /// order, the next `blockIndices[1].count` scalars are the scalars for the second block in
  /// row major order, etc.
  public fileprivate(set) var scalars: [Double]
}

/// The indices for a block in a `BlockMatrix`.
public struct BlockMatrixIndices: Equatable {
  /// The indices of the rows and columns of this block.
  public let rowIndices, columnIndices: Range<Int>

  /// The number of scalars in this block.
  public var count: Int {
    return rowIndices.count * columnIndices.count
  }
}

/// Initializers.
extension BlockMatrix {
  /// Creates a `BlockMatrix` with the givien `scalars` and `blockIndices`.
  ///
  /// Note: This is fileprivate so that clients use more convienient helpers to initialize
  /// `BlockMatrix`es.
  ///
  /// Precondition: `scalars.count` is the same as the sum of all the `blockIndices` counts.
  fileprivate init(_ scalars: [Double], blockIndices: [BlockMatrixIndices]) {
    precondition(scalars.count == blockIndices.map { $0.count }.reduce(0, +))
    self.scalars = scalars
    self.blockIndices = blockIndices
  }

  /// Creates a `BlockMatrix` with `rows`.
  ///
  /// If `rowIndices` or `columnIndices` are specified, the block of rows is placed at the
  /// specified indices. Otherwise, the block is placed starting at row 0 column 0.
  ///
  /// Precondition: All elements of `rows` have the same count.
  /// Precondition: If `rowIndices` is specified, then it has the same count as `rows`.
  /// Precondition: If `columnIndices` is specified, then it has the same count as an element of
  /// `rows`.
  public init(_ rows: [[Double]], rowIndices: Range<Int>? = nil, columnIndices: Range<Int>? = nil) {
    let rowIndices = rowIndices ?? 0..<rows.count
    precondition(rowIndices.count == rows.count)

    guard rows.count > 0 else {
      self.init([], blockIndices: [])
      return
    }

    let columnIndices = columnIndices ?? 0..<rows[0].count
    var scalars: [Double] = []
    scalars.reserveCapacity(rowIndices.count * columnIndices.count)
    for row in rows {
      scalars.append(contentsOf: row)
    }
    self.init(scalars, blockIndices: [BlockMatrixIndices(rowIndices: rowIndices, columnIndices: columnIndices)])
  }

  /// Creates an identity matrix of size `dimension` x `dimension`, starting at row 0 column 0.
  public init(eye dimension: Int, rowIndices: Range<Int>? = nil, columnIndices: Range<Int>? = nil) {
    let zeros = Array(repeating: Double(0), count: dimension)
    var rows: [[Double]] = Array(repeating: zeros, count: dimension)
    for i in 0..<dimension {
      rows[i][i] = 1
    }
    self.init(rows)
  }

  /// Creates a matrix stacking the given rows.
  ///
  /// Precondition: The block structure of each element of `rows` is the same.
  init(rows: [BlockVector]) {
    guard rows.count > 0 else {
      self.init([], blockIndices: [])
      return
    }

    for row in rows {
      if row.blockIndices != rows[0].blockIndices {
        preconditionFailure("rows have different block structures")
      }
    }

    var scalars: [Double] = []
    scalars.reserveCapacity(rows.count * rows[0].blockIndices.map { $0.count }.reduce(0, +))
    var blockIndices: [BlockMatrixIndices] = []
    blockIndices.reserveCapacity(rows[0].blockIndices.count)
    var rowOffset = 0
    for columnIndices in rows[0].blockIndices {
      blockIndices.append(BlockMatrixIndices(rowIndices: 0..<rows.count, columnIndices: columnIndices))
      for row in rows {
        scalars.append(contentsOf: row.scalars[rowOffset..<(rowOffset + columnIndices.count)])
      }
      rowOffset += columnIndices.count
    }
    self.init(scalars, blockIndices: blockIndices)
  }
}

/// Miscellaneous utilities.
extension BlockMatrix {
  /// The number of rows in the matrix, determined by the row with the highest index.
  public var rowCount: Int {
    return blockIndices.map { $0.rowIndices.upperBound }.max() ?? 0
  }

  /// The number of columns in the matrix, determined by the column with the highest index.
  public var columnCount: Int {
    return blockIndices.map { $0.columnIndices.upperBound }.max() ?? 0
  }

  /// Returns this matrix as a `Tensor<Double>`.
  public var tensor: Tensor<Double> {
    var tensor = Tensor<Double>(zeros: [rowCount, columnCount])
    var scalarIndex = 0
    for block in blockIndices {
      for i in block.rowIndices {
        for j in block.columnIndices {
          tensor[i, j] = Tensor(scalars[scalarIndex])
          scalarIndex += 1
        }
      }
    }
    return tensor
  }
}

extension BlockMatrix {
  /// Returns `true` iff the block structures and scalars of `self` and `other` are the same.
  public func blocksEqual(_ other: BlockMatrix) -> Bool {
    return self.blockIndices == other.blockIndices && self.scalars == other.scalars
  }
}

extension BlockMatrix {
  /// Returns the matrix with row indices offset by `rowOffset` and column indices offset by
  /// `columnOffset`.
  public func offsetting(rowBy rowOffset: Int = 0, columnBy columnOffset: Int = 0) -> BlockMatrix {
    return BlockMatrix(
      scalars,
      blockIndices: blockIndices.map { block in
        return BlockMatrixIndices(
          rowIndices: block.rowIndices.offsetting(by: rowOffset),
          columnIndices: block.columnIndices.offsetting(by: columnOffset)
        )
      }
    )
  }
}

/// Matrix arithmetic.
extension BlockMatrix {
  /// Adds `rhs` to `lhs`.
  public static func += (_ lhs: inout BlockMatrix, _ rhs: BlockMatrix) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  /// Returns the sum of `lhs` and `rhs`.
  public static func + (_ lhs: BlockMatrix, _ rhs: BlockMatrix) -> BlockMatrix {
    var result = lhs
    result += rhs
    return result
  }

  /// Returns the scalar product of `lhs` with `rhs`.
  public static func * (_ lhs: Double, _ rhs: BlockMatrix) -> BlockMatrix {
    return BlockMatrix(rhs.scalars.map { lhs * $0 }, blockIndices: rhs.blockIndices)
  }

  /// Returns the matrix-vector product of `lhs` with `rhs`.
  public static func * (_ lhs: BlockMatrix, _ rhs: Vector) -> Vector {
    let outputDimension = lhs.blockIndices.map { $0.rowIndices.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blockIndices {
      for rowIndex in block.rowIndices {
        for columnIndex in block.columnIndices {
          resultScalars[rowIndex] += lhs.scalars[scalarsIndex] * rhs.scalars[columnIndex]
          scalarsIndex += 1
        }
      }
    }
    return Vector(resultScalars)
  }

  /// Returns the matrix-vector product of the transpose of `self` with `rhs`.
  public func dual(_ rhs: Vector) -> Vector {
    let lhs = self
    let outputDimension = lhs.blockIndices.map { $0.columnIndices.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blockIndices {
      for rowIndex in block.rowIndices {
        for columnIndex in block.columnIndices {
          resultScalars[columnIndex] += lhs.scalars[scalarsIndex] * rhs.scalars[rowIndex]
          scalarsIndex += 1
        }
      }
    }
    return Vector(resultScalars)
  }

  /// Returns an empty `BlockMatrix`.
  public static var zero: BlockMatrix {
    return BlockMatrix([], blockIndices: [])
  }
}
