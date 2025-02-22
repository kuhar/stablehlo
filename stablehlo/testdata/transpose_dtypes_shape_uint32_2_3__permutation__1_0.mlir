// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<2x3xui32>
    %1 = call @expected() : () -> tensor<3x2xui32>
    %2 = stablehlo.transpose %0, dims = [1, 0] : (tensor<2x3xui32>) -> tensor<3x2xui32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xui32>, tensor<3x2xui32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<2x3xui32> {
    %0 = stablehlo.constant dense<[[2, 1, 0], [2, 2, 7]]> : tensor<2x3xui32>
    return %0 : tensor<2x3xui32>
  }
  func.func private @expected() -> tensor<3x2xui32> {
    %0 = stablehlo.constant dense<[[2, 2], [1, 2], [0, 7]]> : tensor<3x2xui32>
    return %0 : tensor<3x2xui32>
  }
}
