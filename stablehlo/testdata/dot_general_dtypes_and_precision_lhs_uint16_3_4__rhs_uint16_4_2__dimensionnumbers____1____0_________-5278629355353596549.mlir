// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<3x4xui16>, tensor<4x2xui16>)
    %1 = call @expected() : () -> tensor<3x2xui16>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>} : (tensor<3x4xui16>, tensor<4x2xui16>) -> tensor<3x2xui16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xui16>, tensor<3x2xui16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x4xui16>, tensor<4x2xui16>) {
    %0 = stablehlo.constant dense<[[0, 4, 2, 0], [1, 3, 2, 1], [6, 2, 1, 5]]> : tensor<3x4xui16>
    %1 = stablehlo.constant dense<[[2, 1], [1, 5], [0, 1], [0, 0]]> : tensor<4x2xui16>
    return %0, %1 : tensor<3x4xui16>, tensor<4x2xui16>
  }
  func.func private @expected() -> tensor<3x2xui16> {
    %0 = stablehlo.constant dense<[[4, 22], [5, 18], [14, 17]]> : tensor<3x2xui16>
    return %0 : tensor<3x2xui16>
  }
}

