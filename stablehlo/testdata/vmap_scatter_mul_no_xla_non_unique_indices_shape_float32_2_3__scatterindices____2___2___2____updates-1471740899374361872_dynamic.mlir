// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x2x3xf32> {mhlo.sharding = ""}, %arg2: tensor<?x2x1x3xf32> {mhlo.sharding = ""}) -> tensor<?x2x3xf32> {
    %0 = stablehlo.constant dense<2> : tensor<1x3x1xi64>
    %1 = "stablehlo.scatter"(%arg1, %0, %arg2) ({
    ^bb0(%arg3: tensor<f32>, %arg4: tensor<f32>):
      %2 = stablehlo.multiply %arg3, %arg4 : tensor<f32>
      stablehlo.return %2 : tensor<f32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2], scatter_dims_to_operand_dims = [2], index_vector_dim = 2>} : (tensor<?x2x3xf32>, tensor<1x3x1xi64>, tensor<?x2x1x3xf32>) -> tensor<?x2x3xf32>
    return %1 : tensor<?x2x3xf32>
  }
}

