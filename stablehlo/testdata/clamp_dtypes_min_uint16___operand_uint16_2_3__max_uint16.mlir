// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:3 = call @inputs() : () -> (tensor<ui16>, tensor<2x3xui16>, tensor<ui16>)
    %1 = call @expected() : () -> tensor<2x3xui16>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [] : (tensor<ui16>) -> tensor<2x3xui16>
    %3 = stablehlo.broadcast_in_dim %0#2, dims = [] : (tensor<ui16>) -> tensor<2x3xui16>
    %4 = stablehlo.clamp %2, %0#1, %3 : tensor<2x3xui16>
    %5 = stablehlo.custom_call @check.eq(%4, %1) : (tensor<2x3xui16>, tensor<2x3xui16>) -> tensor<i1>
    return %5 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<ui16>, tensor<2x3xui16>, tensor<ui16>) {
    %0 = stablehlo.constant dense<[[2, 3, 2], [1, 2, 2]]> : tensor<2x3xui16>
    %1 = stablehlo.constant dense<1> : tensor<ui16>
    %2 = stablehlo.constant dense<1> : tensor<ui16>
    return %1, %0, %2 : tensor<ui16>, tensor<2x3xui16>, tensor<ui16>
  }
  func.func private @expected() -> tensor<2x3xui16> {
    %0 = stablehlo.constant dense<1> : tensor<2x3xui16>
    return %0 : tensor<2x3xui16>
  }
}
