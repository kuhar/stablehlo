// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<1x3x4xi32>, tensor<1x4x3xi32>)
    %1 = call @expected() : () -> tensor<1xi32>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_batching_dimensions = [0], rhs_batching_dimensions = [0], lhs_contracting_dimensions = [2, 1], rhs_contracting_dimensions = [1, 2]>, precision_config = [#stablehlo<precision HIGH>, #stablehlo<precision HIGH>]} : (tensor<1x3x4xi32>, tensor<1x4x3xi32>) -> tensor<1xi32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<1xi32>, tensor<1xi32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x3x4xi32>, tensor<1x4x3xi32>) {
    %0 = stablehlo.constant dense<[[[0, 1, 0, 0], [-5, -5, -7, -3], [-2, -2, 4, 6]]]> : tensor<1x3x4xi32>
    %1 = stablehlo.constant dense<[[[2, 0, 0], [0, -6, 0], [2, -3, -3], [5, 2, 1]]]> : tensor<1x4x3xi32>
    return %0, %1 : tensor<1x3x4xi32>, tensor<1x4x3xi32>
  }
  func.func private @expected() -> tensor<1xi32> {
    %0 = stablehlo.constant dense<39> : tensor<1xi32>
    return %0 : tensor<1xi32>
  }
}
