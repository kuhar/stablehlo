// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x1x2x3xf32> {mhlo.sharding = ""}, %arg2: tensor<?x1xf32> {mhlo.sharding = ""}) -> tensor<?x1x2x3xf32> {
    %0 = stablehlo.constant dense<[1, 2]> : tensor<2xi64>
    %1 = "stablehlo.scatter"(%arg1, %0, %arg2) ({
    ^bb0(%arg3: tensor<f32>, %arg4: tensor<f32>):
      %2 = stablehlo.multiply %arg3, %arg4 : tensor<f32>
      stablehlo.return %2 : tensor<f32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2, 3], scatter_dims_to_operand_dims = [2, 3]>, unique_indices = true} : (tensor<?x1x2x3xf32>, tensor<2xi64>, tensor<?x1xf32>) -> tensor<?x1x2x3xf32>
    return %1 : tensor<?x1x2x3xf32>
  }
}

