public struct Vector: Differentiable {
  @differentiable
  public var scalars: [Double]

  @differentiable
  public init(_ scalars: [Double]) {
    self.scalars = scalars
  }
}

extension Vector: VectorProtocol {
  public typealias VectorSpaceScalar = Double

  public var norm: Double { squaredNorm.squareRoot() }

  public var squaredNorm: Double { self.squared().sum() }

  public static func += (_ lhs: inout Vector, _ rhs: Vector) {
    for index in withoutDerivative(at: lhs.scalars.indices) {
      lhs.scalars[index] += rhs.scalars[index]
    }
  }

  public static func + (_ lhs: Vector, _ rhs: Vector) -> Vector {
    var result = lhs
    result += rhs
    return result
  }

  public static func -= (_ lhs: inout Vector, _ rhs: Vector) {
    for index in withoutDerivative(at: lhs.scalars.indices) {
      lhs.scalars[index] += rhs.scalars[index]
    }
  }

  public static func - (_ lhs: Vector, _ rhs: Vector) -> Vector {
    var result = lhs
    result -= rhs
    return result
  }

  public mutating func add(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] += x
    }
  }

  public func adding(_ x: Double) -> Vector {
    var result = self
    result.add(x)
    return result
  }

  public mutating func subtract(_ x: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] -= x
    }
  }

  public func subtracting(_ x: Double) -> Vector {
    var result = self
    result.subtract(x)
    return result
  }

  public mutating func scale(by scalar: Double) {
    for index in withoutDerivative(at: scalars.indices) {
      scalars[index] *= scalar
    }
  }

  public func scaled(by scalar: Double) -> Vector {
    var result = self
    result.scale(by: scalar)
    return result
  }

  public static func * (_ lhs: Double, _ rhs: Vector) -> Vector {
    return rhs.scaled(by: lhs)
  }

  public static var zero: Vector {
    // TODO: Note.
    return Vector([])
  }
}

extension Vector {
  public func sum() -> Double {
    return scalars.reduce(0, +)
  }

  public func squared() -> Self {
    return Vector(scalars.map { $0 * $0 })
  }
}

extension Vector {
  public init(zeros dimension: Int) {
    self.init(Array(repeating: 0, count: dimension))
  }
}
