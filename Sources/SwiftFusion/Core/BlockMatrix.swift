import TensorFlow

public struct BlockMatrix {
  public private(set) var scalars: [Double]
  public private(set) var blockIndices: [BlockMatrixIndices]

  fileprivate init(_ scalars: [Double], blockIndices: [BlockMatrixIndices]) {
    self.scalars = scalars
    self.blockIndices = blockIndices
  }
}

extension BlockMatrix {
  init(rows: [BlockVector]) {
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

  public init(eye dimension: Int) {
    let zeros = Array(repeating: Double(0), count: dimension)
    var rows: [[Double]] = Array(repeating: zeros, count: dimension)
    for i in 0..<dimension {
      rows[i][i] = 1
    }
    self.init(rows)
  }
}

extension BlockMatrix {
  public var rowCount: Int {
    return blockIndices.map { $0.rowIndices.upperBound }.max() ?? 0
  }

  public var columnCount: Int {
    return blockIndices.map { $0.columnIndices.upperBound }.max() ?? 0
  }

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
  public func blocksEqual(_ other: BlockMatrix) -> Bool {
    return self.blockIndices == other.blockIndices && self.scalars == other.scalars
  }
}

extension BlockMatrix {
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

extension BlockMatrix {
  public static func += (_ lhs: inout BlockMatrix, _ rhs: BlockMatrix) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blockIndices.append(contentsOf: rhs.blockIndices)
  }

  public static func + (_ lhs: BlockMatrix, _ rhs: BlockMatrix) -> BlockMatrix {
    var result = lhs
    result += rhs
    return result
  }

  public static var zero: BlockMatrix {
    return BlockMatrix([], blockIndices: [])
  }
}

extension BlockMatrix {
  public static func * (_ lhs: Double, _ rhs: BlockMatrix) -> BlockMatrix {
    return BlockMatrix(rhs.scalars.map { lhs * $0 }, blockIndices: rhs.blockIndices)
  }
}

extension BlockMatrix {
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
}

public struct BlockMatrixIndices: Equatable {
  public let rowIndices, columnIndices: Range<Int>
}

fileprivate extension Range where Bound == Int {
  func offsetting(by offset: Int) -> Range {
    return (lowerBound + offset)..<(upperBound + offset)
  }
}
