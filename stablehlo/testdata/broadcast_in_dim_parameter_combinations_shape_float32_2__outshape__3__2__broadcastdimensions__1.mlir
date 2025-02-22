// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<2xf32>
    %1 = call @expected() : () -> tensor<3x2xf32>
    %2 = stablehlo.broadcast_in_dim %0, dims = [1] : (tensor<2xf32>) -> tensor<3x2xf32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<3x2xf32>, tensor<3x2xf32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<2xf32> {
    %0 = stablehlo.constant dense<[-1.384990e+00, -1.32965207]> : tensor<2xf32>
    return %0 : tensor<2xf32>
  }
  func.func private @expected() -> tensor<3x2xf32> {
    %0 = stablehlo.constant dense<[[-1.384990e+00, -1.32965207], [-1.384990e+00, -1.32965207], [-1.384990e+00, -1.32965207]]> : tensor<3x2xf32>
    return %0 : tensor<3x2xf32>
  }
}
