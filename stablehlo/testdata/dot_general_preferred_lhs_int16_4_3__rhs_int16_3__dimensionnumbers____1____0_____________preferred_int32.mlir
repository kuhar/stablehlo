// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<4x3xi16>, tensor<3xi16>)
    %1 = call @expected() : () -> tensor<4xi32>
    %2 = "stablehlo.dot_general"(%0#0, %0#1) {dot_dimension_numbers = #stablehlo.dot<lhs_contracting_dimensions = [1], rhs_contracting_dimensions = [0]>} : (tensor<4x3xi16>, tensor<3xi16>) -> tensor<4xi32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<4xi32>, tensor<4xi32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<4x3xi16>, tensor<3xi16>) {
    %0 = stablehlo.constant dense<[[0, 0, 4], [2, -1, -1], [-2, -1, 1], [0, 0, 0]]> : tensor<4x3xi16>
    %1 = stablehlo.constant dense<[0, 0, 4]> : tensor<3xi16>
    return %0, %1 : tensor<4x3xi16>, tensor<3xi16>
  }
  func.func private @expected() -> tensor<4xi32> {
    %0 = stablehlo.constant dense<[16, -4, 4, 0]> : tensor<4xi32>
    return %0 : tensor<4xi32>
  }
}

