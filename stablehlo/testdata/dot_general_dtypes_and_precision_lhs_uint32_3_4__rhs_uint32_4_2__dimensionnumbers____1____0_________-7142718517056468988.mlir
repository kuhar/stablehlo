// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<3x4xui32>, tensor<4x2xui32>)
    %1 = call @expected() : () -> tensor<3x2xui32>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>, precision_config = [#stablehlo<precision HIGHEST>, #stablehlo<precision HIGHEST>]} : (tensor<3x4xui32>, tensor<4x2xui32>) -> tensor<3x2xui32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xui32>, tensor<3x2xui32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x4xui32>, tensor<4x2xui32>) {
    %0 = stablehlo.constant dense<[[0, 2, 1, 2], [3, 7, 3, 2], [7, 5, 0, 4]]> : tensor<3x4xui32>
    %1 = stablehlo.constant dense<[[8, 1], [1, 1], [2, 2], [1, 1]]> : tensor<4x2xui32>
    return %0, %1 : tensor<3x4xui32>, tensor<4x2xui32>
  }
  func.func private @expected() -> tensor<3x2xui32> {
    %0 = stablehlo.constant dense<[[6, 6], [39, 18], [65, 16]]> : tensor<3x2xui32>
    return %0 : tensor<3x2xui32>
  }
}
