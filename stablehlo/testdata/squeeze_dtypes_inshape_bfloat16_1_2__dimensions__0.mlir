// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<1x2xbf16>
    %1 = call @expected() : () -> tensor<2xbf16>
    %2 = stablehlo.reshape %0 : (tensor<1x2xbf16>) -> tensor<2xbf16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2xbf16>, tensor<2xbf16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<1x2xbf16> {
    %0 = stablehlo.constant dense<[[-2.343750e+00, 7.343750e-01]]> : tensor<1x2xbf16>
    return %0 : tensor<1x2xbf16>
  }
  func.func private @expected() -> tensor<2xbf16> {
    %0 = stablehlo.constant dense<[-2.343750e+00, 7.343750e-01]> : tensor<2xbf16>
    return %0 : tensor<2xbf16>
  }
}
