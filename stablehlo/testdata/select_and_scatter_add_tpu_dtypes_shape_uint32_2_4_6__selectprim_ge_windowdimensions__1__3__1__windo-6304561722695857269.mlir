// RUN-DISABLED: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<2x1x6xui32>, tensor<2x4x6xui32>)
    %1 = call @expected() : () -> tensor<2x4x6xui32>
    %2 = stablehlo.constant dense<0> : tensor<ui32>
    %3 = stablehlo.pad %0#1, %2, low = [0, 0, 0], high = [0, 0, 0], interior = [0, 0, 0] : (tensor<2x4x6xui32>, tensor<ui32>) -> tensor<2x4x6xui32>
    %4 = stablehlo.constant dense<0> : tensor<ui32>
    %5 = "stablehlo.select_and_scatter"(%3, %0#0, %4) ({
    ^bb0(%arg0: tensor<ui32>, %arg1: tensor<ui32>):
      %8 = stablehlo.compare  GE, %arg0, %arg1,  UNSIGNED : (tensor<ui32>, tensor<ui32>) -> tensor<i1>
      stablehlo.return %8 : tensor<i1>
    }, {
    ^bb0(%arg0: tensor<ui32>, %arg1: tensor<ui32>):
      %8 = stablehlo.add %arg0, %arg1 : tensor<ui32>
      stablehlo.return %8 : tensor<ui32>
    }) {window_dimensions = dense<[1, 3, 1]> : tensor<3xi64>, window_strides = dense<[1, 2, 1]> : tensor<3xi64>} : (tensor<2x4x6xui32>, tensor<2x1x6xui32>, tensor<ui32>) -> tensor<2x4x6xui32>
    %6 = "stablehlo.slice"(%5) {limit_indices = dense<[2, 4, 6]> : tensor<3xi64>, start_indices = dense<0> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>} : (tensor<2x4x6xui32>) -> tensor<2x4x6xui32>
    %7 = stablehlo.custom_call @check.eq(%6, %1) : (tensor<2x4x6xui32>, tensor<2x4x6xui32>) -> tensor<i1>
    return %7 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<2x1x6xui32>, tensor<2x4x6xui32>) {
    %0 = stablehlo.constant dense<[[[2, 1, 1, 4, 0, 4]], [[4, 2, 3, 3, 0, 1]]]> : tensor<2x1x6xui32>
    %1 = stablehlo.constant dense<[[[0, 2, 1, 0, 3, 0], [0, 2, 2, 4, 0, 0], [0, 1, 2, 1, 5, 1], [0, 1, 0, 5, 5, 1]], [[4, 2, 3, 5, 3, 2], [6, 3, 1, 0, 4, 2], [4, 3, 4, 3, 5, 3], [4, 0, 1, 4, 0, 0]]]> : tensor<2x4x6xui32>
    return %0, %1 : tensor<2x1x6xui32>, tensor<2x4x6xui32>
  }
  func.func private @expected() -> tensor<2x4x6xui32> {
    %0 = stablehlo.constant dense<[[[2, 1, 0, 0, 0, 0], [0, 0, 1, 4, 0, 0], [0, 0, 0, 0, 0, 4], [0, 0, 0, 0, 0, 0]], [[0, 0, 0, 3, 0, 0], [4, 2, 0, 0, 0, 0], [0, 0, 3, 0, 0, 1], [0, 0, 0, 0, 0, 0]]]> : tensor<2x4x6xui32>
    return %0 : tensor<2x4x6xui32>
  }
}

