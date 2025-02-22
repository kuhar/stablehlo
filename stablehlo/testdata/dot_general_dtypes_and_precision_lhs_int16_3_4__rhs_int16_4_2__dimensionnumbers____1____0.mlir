// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<3x4xi16>, tensor<4x2xi16>)
    %1 = call @expected() : () -> tensor<3x2xi16>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>} : (tensor<3x4xi16>, tensor<4x2xi16>) -> tensor<3x2xi16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xi16>, tensor<3x2xi16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x4xi16>, tensor<4x2xi16>) {
    %0 = stablehlo.constant dense<[[3, 0, 0, 4], [0, 4, -1, 2], [-2, -3, 0, -5]]> : tensor<3x4xi16>
    %1 = stablehlo.constant dense<[[0, 3], [-1, 0], [1, -2], [1, -2]]> : tensor<4x2xi16>
    return %0, %1 : tensor<3x4xi16>, tensor<4x2xi16>
  }
  func.func private @expected() -> tensor<3x2xi16> {
    %0 = stablehlo.constant dense<[[4, 1], [-3, -2], [-2, 4]]> : tensor<3x2xi16>
    return %0 : tensor<3x2xi16>
  }
}

