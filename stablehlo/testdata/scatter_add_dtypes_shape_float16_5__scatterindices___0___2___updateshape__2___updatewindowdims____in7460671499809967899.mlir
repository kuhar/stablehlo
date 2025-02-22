// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[0], [2]]> : tensor<2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<5xf16>, tensor<2xf16>)
    %2 = call @expected() : () -> tensor<5xf16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<f16>, %arg1: tensor<f16>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<f16>
      stablehlo.return %5 : tensor<f16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<inserted_window_dims = [0], scatter_dims_to_operand_dims = [0], index_vector_dim = 1>} : (tensor<5xf16>, tensor<2x1xi32>, tensor<2xf16>) -> tensor<5xf16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5xf16>, tensor<5xf16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5xf16>, tensor<2xf16>) {
    %0 = stablehlo.constant dense<[5.375000e+00, 1.038090e+00, -4.968750e+00, -1.841800e+00, -2.505860e+00]> : tensor<5xf16>
    %1 = stablehlo.constant dense<[4.401860e-01, -2.437500e+00]> : tensor<2xf16>
    return %0, %1 : tensor<5xf16>, tensor<2xf16>
  }
  func.func private @expected() -> tensor<5xf16> {
    %0 = stablehlo.constant dense<[5.816400e+00, 1.038090e+00, -7.406250e+00, -1.841800e+00, -2.505860e+00]> : tensor<5xf16>
    return %0 : tensor<5xf16>
  }
}

