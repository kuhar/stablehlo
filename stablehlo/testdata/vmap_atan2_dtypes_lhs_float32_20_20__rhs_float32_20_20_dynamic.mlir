// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x20x20xf32> {mhlo.sharding = ""}, %arg2: tensor<?x20x20xf32> {mhlo.sharding = ""}) -> tensor<?x20x20xf32> {
    %0 = stablehlo.atan2 %arg1, %arg2 : tensor<?x20x20xf32>
    return %0 : tensor<?x20x20xf32>
  }
}

