// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<1x2xui32>
    %1 = call @expected() : () -> tensor<2xui32>
    %2 = stablehlo.reshape %0 : (tensor<1x2xui32>) -> tensor<2xui32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2xui32>, tensor<2xui32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<1x2xui32> {
    %0 = stablehlo.constant dense<[[1, 3]]> : tensor<1x2xui32>
    return %0 : tensor<1x2xui32>
  }
  func.func private @expected() -> tensor<2xui32> {
    %0 = stablehlo.constant dense<[1, 3]> : tensor<2xui32>
    return %0 : tensor<2xui32>
  }
}
