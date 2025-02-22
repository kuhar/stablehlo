// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<0> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x2x3xf32>, tensor<2x3xf32>)
    %2 = call @expected() : () -> tensor<1x2x3xf32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      stablehlo.return %arg1 : tensor<f32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [0], scatter_dims_to_operand_dims = [0]>, unique_indices = true} : (tensor<1x2x3xf32>, tensor<1xi32>, tensor<2x3xf32>) -> tensor<1x2x3xf32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x2x3xf32>, tensor<1x2x3xf32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x2x3xf32>, tensor<2x3xf32>) {
    %0 = stablehlo.constant dense<[[[-1.45246243, -1.6785903, 5.42458868], [1.67983925, -2.69965839, 0.816186905]]]> : tensor<1x2x3xf32>
    %1 = stablehlo.constant dense<[[-2.5465498, 1.19803405, 1.06255829], [-4.82208633, -3.57861257, 2.37609673]]> : tensor<2x3xf32>
    return %0, %1 : tensor<1x2x3xf32>, tensor<2x3xf32>
  }
  func.func private @expected() -> tensor<1x2x3xf32> {
    %0 = stablehlo.constant dense<[[[-2.5465498, 1.19803405, 1.06255829], [-4.82208633, -3.57861257, 2.37609673]]]> : tensor<1x2x3xf32>
    return %0 : tensor<1x2x3xf32>
  }
}

