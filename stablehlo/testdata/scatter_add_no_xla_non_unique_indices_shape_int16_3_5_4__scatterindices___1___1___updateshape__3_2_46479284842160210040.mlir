// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<1> : tensor<2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<3x5x4xi16>, tensor<3x2x4xi16>)
    %2 = call @expected() : () -> tensor<3x5x4xi16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i16>, %arg1: tensor<i16>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<i16>
      stablehlo.return %5 : tensor<i16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 2], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 1>} : (tensor<3x5x4xi16>, tensor<2x1xi32>, tensor<3x2x4xi16>) -> tensor<3x5x4xi16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<3x5x4xi16>, tensor<3x5x4xi16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x5x4xi16>, tensor<3x2x4xi16>) {
    %0 = stablehlo.constant dense<[[[-2, -1, 4, 3], [0, -1, 2, 0], [1, -1, -2, 2], [4, 2, 0, 0], [3, 2, -3, -4]], [[0, 0, 0, 5], [-1, -2, 5, 2], [2, -3, 1, 0], [1, 0, -2, 0], [-4, 2, -3, 1]], [[2, -5, 0, -2], [0, 3, 0, -1], [-1, -1, 0, 2], [7, 6, 2, 4], [-8, -1, 2, 5]]]> : tensor<3x5x4xi16>
    %1 = stablehlo.constant dense<[[[3, 0, 0, -4], [0, -2, 0, 0]], [[-1, 5, 2, -1], [-1, 1, -2, 0]], [[0, 1, 0, 0], [6, 4, -2, 0]]]> : tensor<3x2x4xi16>
    return %0, %1 : tensor<3x5x4xi16>, tensor<3x2x4xi16>
  }
  func.func private @expected() -> tensor<3x5x4xi16> {
    %0 = stablehlo.constant dense<[[[-2, -1, 4, 3], [3, -3, 2, -4], [1, -1, -2, 2], [4, 2, 0, 0], [3, 2, -3, -4]], [[0, 0, 0, 5], [-3, 4, 5, 1], [2, -3, 1, 0], [1, 0, -2, 0], [-4, 2, -3, 1]], [[2, -5, 0, -2], [6, 8, -2, -1], [-1, -1, 0, 2], [7, 6, 2, 4], [-8, -1, 2, 5]]]> : tensor<3x5x4xi16>
    return %0 : tensor<3x5x4xi16>
  }
}

