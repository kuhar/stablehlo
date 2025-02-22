// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x100x100xi8> {mhlo.sharding = ""}) -> tensor<?x100x100xcomplex<f64>> {
    %0 = stablehlo.convert %arg1 : (tensor<?x100x100xi8>) -> tensor<?x100x100xcomplex<f64>>
    return %0 : tensor<?x100x100xcomplex<f64>>
  }
}

