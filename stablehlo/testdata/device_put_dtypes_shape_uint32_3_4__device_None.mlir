// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<3x4xui32>
    %1 = call @expected() : () -> tensor<3x4xui32>
    %2 = stablehlo.custom_call @check.eq(%0, %1) : (tensor<3x4xui32>, tensor<3x4xui32>) -> tensor<i1>
    return %2 : tensor<i1>
  }
  func.func private @inputs() -> tensor<3x4xui32> {
    %0 = stablehlo.constant dense<[[3, 0, 3, 4], [5, 0, 2, 1], [1, 0, 6, 1]]> : tensor<3x4xui32>
    return %0 : tensor<3x4xui32>
  }
  func.func private @expected() -> tensor<3x4xui32> {
    %0 = stablehlo.constant dense<[[3, 0, 3, 4], [5, 0, 2, 1], [1, 0, 6, 1]]> : tensor<3x4xui32>
    return %0 : tensor<3x4xui32>
  }
}
