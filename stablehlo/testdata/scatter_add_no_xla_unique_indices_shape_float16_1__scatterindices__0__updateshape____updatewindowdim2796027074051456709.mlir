// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<0> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1xf16>, tensor<f16>)
    %2 = call @expected() : () -> tensor<1xf16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<f16>, %arg1: tensor<f16>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<f16>
      stablehlo.return %5 : tensor<f16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<inserted_window_dims = [0], scatter_dims_to_operand_dims = [0]>, unique_indices = true} : (tensor<1xf16>, tensor<1xi32>, tensor<f16>) -> tensor<1xf16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1xf16>, tensor<1xf16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1xf16>, tensor<f16>) {
    %0 = stablehlo.constant dense<3.642580e+00> : tensor<1xf16>
    %1 = stablehlo.constant dense<2.189450e+00> : tensor<f16>
    return %0, %1 : tensor<1xf16>, tensor<f16>
  }
  func.func private @expected() -> tensor<1xf16> {
    %0 = stablehlo.constant dense<5.832030e+00> : tensor<1xf16>
    return %0 : tensor<1xf16>
  }
}

