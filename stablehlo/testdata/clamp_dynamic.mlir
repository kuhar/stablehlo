// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x4x5xf32> {mhlo.sharding = ""}, %arg2: tensor<?x4x5xf32> {mhlo.sharding = ""}, %arg3: tensor<?x4x5xf32> {mhlo.sharding = ""}) -> tensor<?x4x5xf32> {
    %0 = stablehlo.clamp %arg1, %arg2, %arg3 : tensor<?x4x5xf32>
    return %0 : tensor<?x4x5xf32>
  }
}

