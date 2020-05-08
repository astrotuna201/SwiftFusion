import TensorFlow

/// Generic Lie Group protocol
public protocol LieGroup: Manifold {
  @differentiable(wrt: (lhs, rhs))
  static func * (_ lhs: Self, _ rhs: Self) -> Self
  
  @differentiable
  func inverse() -> Self
  
  @differentiable(wrt: global)
  func local(_ global: Self) -> Self.Coordinate.LocalCoordinate
}

// TODO(TF-1234): Remove this extension. It is a workaround.
extension LieGroup {
  /// Use this instead of "*" to worok around TF-1234.
  @differentiable
  static func differentiableMultiply(_ lhs: Self, _ rhs: Self) -> Self {
    return lhs * rhs
  }

  /// Use this instead of "inverse" to worok around TF-1234.
  @differentiable
  func differentiableInverse() -> Self {
    return inverse()
  }

  /// Use this instead of "local" to worok around TF-1234.
  @differentiable(wrt: global)
  func differentiableLocal(_ global: Self) -> Self.Coordinate.LocalCoordinate {
    return local(global)
  }
}