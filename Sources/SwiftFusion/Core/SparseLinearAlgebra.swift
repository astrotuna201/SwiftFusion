public struct SparseVector: Differentiable {
  fileprivate var scalars: [Double]
  @noDerivative fileprivate var blocks: [Range<Int>]

  public typealias TangentVector = Self

  fileprivate init(_ scalars: [Double], blocks: [Range<Int>]) {
    self.scalars = scalars
    self.blocks = blocks
  }
}

extension SparseVector {
  public init(_ scalars: [Double]) {
    self.scalars = scalars
    self.blocks = [scalars.indices]
  }

  public init(_ scalars: [Double], block: Range<Int>) {
    self.scalars = scalars
    self.blocks = [block]
  }
}

extension SparseVector {
  public var dimension: Int {
    return blocks.map { $0.upperBound }.max() ?? 0
  }
}

extension SparseVector: VectorProtocol {
  public typealias VectorSpaceScalar = Double

  public static func += (_ lhs: inout SparseVector, _ rhs: SparseVector) {
    lhs.scalars.append(contentsOf: rhs.scalars)
    lhs.blocks.append(contentsOf: rhs.blocks)
  }

  public static func + (_ lhs: SparseVector, _ rhs: SparseVector) -> SparseVector {
    var result = lhs
    result += rhs
    return result
  }

  public static func -= (_ lhs: inout SparseVector, _ rhs: SparseVector) {
    lhs.scalars.append(contentsOf: rhs.scalars.map { -$0 })
    lhs.blocks.append(contentsOf: rhs.blocks)
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
    return SparseVector([], blocks: [])
  }
}

fileprivate struct MatrixRange {
  let rowRange, columnRange: Range<Int>
}

public struct SparseMatrix {
  fileprivate var scalars: [Double]
  fileprivate var blocks: [MatrixRange]

  fileprivate init(_ scalars: [Double], blocks: [MatrixRange]) {
    self.scalars = scalars
    self.blocks = blocks
  }
}

extension SparseMatrix {
  init(rows: [SparseVector]) {
    guard rows.count > 0 else {
      self.init([], blocks: [])
      return
    }

    for row in rows {
      if row.blocks != rows[0].blocks {
        fatalError("non-collatable row case unimplemented")
      }
    }

    var scalars: [Double] = []
    scalars.reserveCapacity(rows.count * rows[0].blocks.map { $0.count }.reduce(0, +))
    var blocks: [MatrixRange] = []
    blocks.reserveCapacity(rows[0].blocks.count)
    var rowOffset = 0
    for columnRange in rows[0].blocks {
      blocks.append(MatrixRange(rowRange: 0..<rows.count, columnRange: columnRange))
      for row in rows {
        scalars.append(contentsOf: row.scalars[rowOffset..<(rowOffset + columnRange.count)])
      }
      rowOffset += columnRange.count
    }
    self.init(scalars, blocks: blocks)
  }
}

extension SparseMatrix {
  public func offsetting(rowBy offset: Int) -> SparseMatrix {
    return SparseMatrix(
      scalars,
      blocks: blocks.map { block in
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
    lhs.blocks.append(contentsOf: rhs.blocks)
  }

  public static var zero: SparseMatrix {
    return SparseMatrix([], blocks: [])
  }
}

extension SparseMatrix {
  public static func * (_ lhs: SparseMatrix, _ rhs: Vector) -> Vector {
    let outputDimension = lhs.blocks.map { $0.rowRange.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blocks {
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
    let outputDimension = lhs.blocks.map { $0.columnRange.upperBound }.max() ?? 0
    var resultScalars = Array(repeating: Double(0), count: outputDimension)
    var scalarsIndex = 0
    for block in lhs.blocks {
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
