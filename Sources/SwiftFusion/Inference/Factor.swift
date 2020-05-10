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

/// The most general factor protocol.
public protocol Factor {
  var keys: Array<Int> { get }
}

/// A `NonlinearFactor` corresponds to the `NonlinearFactor` in GTSAM.
public protocol NonlinearFactor: Factor {
  typealias ScalarType = Double

  /// Returns the `error` of the factor.
  @differentiable(wrt: values)
  func error(_ values: Values) -> ScalarType

  /// Returns a single-factor `GaussianFactorGraph` containing the linearization of this factor
  /// around `values`.
  func linearized(_ values: Values) -> GaussianFactorGraph
}
