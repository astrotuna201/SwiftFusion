// A jacobian can be calculated by applying the pullback (reverse mode) to the basis vectors of
// the result tangent type, or by applying the differential (forward mode) to the basis vectors of
// the input tangent type.
//
// Swift doesn't yet completely support forward mode, so we'll only do the reverse mode version.

/// Returns the value of the function and its jacobian matrix at the given point.
///
/// This is not generic over the `Values` type because of https://bugs.swift.org/browse/SR-12762.
/// Fortunately, SwiftFusion currently only needs jacobians with repect to `Values`.
///
/// Additional Notes
/// ===================
/// For example, if we have an `Values` of `Point2` `pts = [0: p1, 1: p2, 2: p3]` with an operation
/// of `pts[1] - pts[0]`, the jacobian should be
/// ```
/// [ [-1.0, 0.0, 1.0, 0.0, 0.0, 0.0]
///   [0.0, -1.0, 0.0, 1.0, 0.0, 0.0] ]
/// ```
public func valueWithJacobian<B: Differentiable>(
  of f: @differentiable (Values) -> B,
  at p: Values
) -> (value: B, jacobian: SparseMatrix) where B.TangentVector: FixedDimensionVector {
  let (value, pb) = valueWithPullback(at: p, in: f)
  return (value: value, jacobian: SparseMatrix(rows: B.TangentVector.standardBasis.map(pb)))
}

/// https://bugs.swift.org/browse/SR-12762
public func jacobian<A: Differentiable, B: Differentiable>(
  of f: @differentiable (A) -> B,
  at p: A
) -> SparseMatrix where A.TangentVector: FixedDimensionVector, B.TangentVector: FixedDimensionVector {
  var values = Values()
  values.insert(0, p)
  return valueWithJacobian(of: { f($0[0, as: A.self]) }, at: values).jacobian
}

