// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<0> : tensor<2x2xui8>
    %1 = call @expected() : () -> tensor<2x2xui8>
    %2 = stablehlo.constant dense<0> : tensor<ui8>
    %3 = stablehlo.broadcast_in_dim %2, dims = [] : (tensor<ui8>) -> tensor<2x2xui8>
    %4 = stablehlo.compare  EQ, %0, %3,  UNSIGNED : (tensor<2x2xui8>, tensor<2x2xui8>) -> tensor<2x2xi1>
    %5 = stablehlo.constant dense<0> : tensor<ui8>
    %6 = stablehlo.broadcast_in_dim %5, dims = [] : (tensor<ui8>) -> tensor<2x2xui8>
    %7 = stablehlo.constant dense<1> : tensor<ui8>
    %8 = stablehlo.broadcast_in_dim %7, dims = [] : (tensor<ui8>) -> tensor<2x2xui8>
    %9 = stablehlo.select %4, %6, %8 : tensor<2x2xi1>, tensor<2x2xui8>
    %10 = stablehlo.custom_call @check.eq(%9, %1) : (tensor<2x2xui8>, tensor<2x2xui8>) -> tensor<i1>
    return %10 : tensor<i1>
  }
  func.func private @expected() -> tensor<2x2xui8> {
    %0 = stablehlo.constant dense<0> : tensor<2x2xui8>
    return %0 : tensor<2x2xui8>
  }
}
