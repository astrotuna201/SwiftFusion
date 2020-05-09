// WARNING: This is a generated file. Do not edit it. Instead, edit the corresponding ".gyb" file.
// See "generate.sh" in the root of this repository for instructions how to regenerate files.

// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 1)
import TensorFlow

public protocol FixedDimensionVector {
  static var dimension: Int { get }
  static var standardBasis: [Self] { get }
  var scalars: [Double] { get }
  init<T: Collection>(_ scalars: T) where T.Element == Double
}

// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 13)

/// An element of R^1, with Euclidean norm.
public struct Vector1: Differentiable, KeyPathIterable, TangentStandardBasis
{
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var x: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 20)

  @differentiable
  public init(_ x: Double) {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.x = x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 26)
  }
}

/// Normed vector space methods.
extension Vector1: AdditiveArithmetic, VectorProtocol {
  public typealias VectorSpaceScalar = Double

  /// Euclidean norm of `self`.
  @differentiable
  public var norm: Double { squaredNorm.squareRoot() }

  /// Square of the Euclidean norm of `self`.
  @differentiable
  public var squaredNorm: Double { self.squared().sum() }

  @differentiable
  public static func + (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.x = lhs.x + rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 47)
    return result
  }

  @differentiable
  public static func - (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.x = lhs.x - rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 56)
    return result
  }

  @differentiable
  public static prefix func - (_ v: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.x = -v.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 65)
    return result
  }
}

/// Other arithmetic on the vector elements.
extension Vector1: ElementaryFunctions {
  /// Sum of the elements of `self`.
  public func sum() -> Double {
    var result: Double = 0
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 77)
    return result
  }

  /// Vector whose elements are squares of the elements of `self`.
  public func squared() -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.x = x * x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 86)
    return result
  }
}

/// Conformance to `FixedDimensionVector`.
extension Vector1: FixedDimensionVector {
  public static var dimension: Int { return 1 }

  public static var standardBasis: [Self] {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisx: Self = .zero
    basisx.x = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 99)
    return [basisx]
  }

  public var scalars: [Double] {
    return [x]
  }

  public init<T: Collection>(_ scalars: T) where T.Element == Double {
    var index = scalars.startIndex
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.x = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 112)
  }
}

/// Conversion to/from tensor.
extension Vector1 {
  /// A `Tensor` with shape `[1]` whose elements are the elements of `self`.
  @differentiable
  public var tensor: Tensor<Double> {
    Tensor([x])
  }

  /// Creates a `Vector1` with the same elements as `tensor`.
  ///
  /// Precondition: `tensor` must have shape `[1]`.
  @differentiable
  public init(_ tensor: Tensor<Double>) {
    precondition(tensor.shape == [1])
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.x = tensor[0].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 132)
  }
}

// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 13)

/// An element of R^2, with Euclidean norm.
public struct Vector2: Differentiable, KeyPathIterable, TangentStandardBasis
{
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var x: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var y: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 20)

  @differentiable
  public init(_ x: Double, _ y: Double) {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.x = x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.y = y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 26)
  }
}

/// Normed vector space methods.
extension Vector2: AdditiveArithmetic, VectorProtocol {
  public typealias VectorSpaceScalar = Double

  /// Euclidean norm of `self`.
  @differentiable
  public var norm: Double { squaredNorm.squareRoot() }

  /// Square of the Euclidean norm of `self`.
  @differentiable
  public var squaredNorm: Double { self.squared().sum() }

  @differentiable
  public static func + (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.x = lhs.x + rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.y = lhs.y + rhs.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 47)
    return result
  }

  @differentiable
  public static func - (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.x = lhs.x - rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.y = lhs.y - rhs.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 56)
    return result
  }

  @differentiable
  public static prefix func - (_ v: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.x = -v.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.y = -v.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 65)
    return result
  }
}

/// Other arithmetic on the vector elements.
extension Vector2: ElementaryFunctions {
  /// Sum of the elements of `self`.
  public func sum() -> Double {
    var result: Double = 0
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 77)
    return result
  }

  /// Vector whose elements are squares of the elements of `self`.
  public func squared() -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.x = x * x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.y = y * y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 86)
    return result
  }
}

/// Conformance to `FixedDimensionVector`.
extension Vector2: FixedDimensionVector {
  public static var dimension: Int { return 2 }

  public static var standardBasis: [Self] {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisx: Self = .zero
    basisx.x = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisy: Self = .zero
    basisy.y = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 99)
    return [basisx, basisy]
  }

  public var scalars: [Double] {
    return [x, y]
  }

  public init<T: Collection>(_ scalars: T) where T.Element == Double {
    var index = scalars.startIndex
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.x = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.y = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 112)
  }
}

/// Conversion to/from tensor.
extension Vector2 {
  /// A `Tensor` with shape `[2]` whose elements are the elements of `self`.
  @differentiable
  public var tensor: Tensor<Double> {
    Tensor([x, y])
  }

  /// Creates a `Vector2` with the same elements as `tensor`.
  ///
  /// Precondition: `tensor` must have shape `[2]`.
  @differentiable
  public init(_ tensor: Tensor<Double>) {
    precondition(tensor.shape == [2])
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.x = tensor[0].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.y = tensor[1].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 132)
  }
}

// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 13)

/// An element of R^3, with Euclidean norm.
public struct Vector3: Differentiable, KeyPathIterable, TangentStandardBasis
{
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var x: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var y: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 18)
  @differentiable public var z: Double
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 20)

  @differentiable
  public init(_ x: Double, _ y: Double, _ z: Double) {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.x = x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.y = y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 24)
    self.z = z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 26)
  }
}

/// Normed vector space methods.
extension Vector3: AdditiveArithmetic, VectorProtocol {
  public typealias VectorSpaceScalar = Double

  /// Euclidean norm of `self`.
  @differentiable
  public var norm: Double { squaredNorm.squareRoot() }

  /// Square of the Euclidean norm of `self`.
  @differentiable
  public var squaredNorm: Double { self.squared().sum() }

  @differentiable
  public static func + (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.x = lhs.x + rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.y = lhs.y + rhs.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 45)
    result.z = lhs.z + rhs.z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 47)
    return result
  }

  @differentiable
  public static func - (_ lhs: Self, _ rhs: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.x = lhs.x - rhs.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.y = lhs.y - rhs.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 54)
    result.z = lhs.z - rhs.z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 56)
    return result
  }

  @differentiable
  public static prefix func - (_ v: Self) -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.x = -v.x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.y = -v.y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 63)
    result.z = -v.z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 65)
    return result
  }
}

/// Other arithmetic on the vector elements.
extension Vector3: ElementaryFunctions {
  /// Sum of the elements of `self`.
  public func sum() -> Double {
    var result: Double = 0
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 75)
    result = result + z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 77)
    return result
  }

  /// Vector whose elements are squares of the elements of `self`.
  public func squared() -> Self {
    var result = Self.zero
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.x = x * x
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.y = y * y
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 84)
    result.z = z * z
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 86)
    return result
  }
}

/// Conformance to `FixedDimensionVector`.
extension Vector3: FixedDimensionVector {
  public static var dimension: Int { return 3 }

  public static var standardBasis: [Self] {
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisx: Self = .zero
    basisx.x = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisy: Self = .zero
    basisy.y = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 96)
    var basisz: Self = .zero
    basisz.z = 1
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 99)
    return [basisx, basisy, basisz]
  }

  public var scalars: [Double] {
    return [x, y, z]
  }

  public init<T: Collection>(_ scalars: T) where T.Element == Double {
    var index = scalars.startIndex
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.x = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.y = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 109)
    self.z = scalars[index]
    index = scalars.index(after: index)
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 112)
  }
}

/// Conversion to/from tensor.
extension Vector3 {
  /// A `Tensor` with shape `[3]` whose elements are the elements of `self`.
  @differentiable
  public var tensor: Tensor<Double> {
    Tensor([x, y, z])
  }

  /// Creates a `Vector3` with the same elements as `tensor`.
  ///
  /// Precondition: `tensor` must have shape `[3]`.
  @differentiable
  public init(_ tensor: Tensor<Double>) {
    precondition(tensor.shape == [3])
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.x = tensor[0].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.y = tensor[1].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 130)
    self.z = tensor[2].scalarized()
// ###sourceLocation(file: "Sources/SwiftFusion/Core/Vector.swift.gyb", line: 132)
  }
}

