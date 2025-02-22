// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<15xf32>
    %1 = call @expected() : () -> tensor<ui8>
    %2 = call @argmax(%0) : (tensor<15xf32>) -> tensor<ui8>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<ui8>, tensor<ui8>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<15xf32> {
    %0 = stablehlo.constant dense<[-0.995230853, 7.61335516, 1.25512362, 2.39964128, 3.468020e-01, 0.227336198, 3.7426219, 0.553802252, -0.816372156, -1.4656173, 2.80029678, 3.84662271, -3.42136121, -2.90006351, -0.889462947]> : tensor<15xf32>
    return %0 : tensor<15xf32>
  }
  func.func private @expected() -> tensor<ui8> {
    %0 = stablehlo.constant dense<1> : tensor<ui8>
    return %0 : tensor<ui8>
  }
  func.func private @argmax(%arg0: tensor<15xf32>) -> tensor<ui8> {
    %0 = stablehlo.iota dim = 0 : tensor<15xui8>
    %1 = stablehlo.constant dense<0xFF800000> : tensor<f32>
    %2 = stablehlo.constant dense<0> : tensor<ui8>
    %3:2 = stablehlo.reduce(%arg0 init: %1), (%0 init: %2) across dimensions = [0] : (tensor<15xf32>, tensor<15xui8>, tensor<f32>, tensor<ui8>) -> (tensor<f32>, tensor<ui8>)
     reducer(%arg1: tensor<f32>, %arg3: tensor<f32>) (%arg2: tensor<ui8>, %arg4: tensor<ui8>)  {
      %4 = stablehlo.compare  GT, %arg1, %arg3,  FLOAT : (tensor<f32>, tensor<f32>) -> tensor<i1>
      %5 = stablehlo.compare  NE, %arg1, %arg1,  FLOAT : (tensor<f32>, tensor<f32>) -> tensor<i1>
      %6 = stablehlo.or %4, %5 : tensor<i1>
      %7 = stablehlo.compare  EQ, %arg1, %arg3,  FLOAT : (tensor<f32>, tensor<f32>) -> tensor<i1>
      %8 = stablehlo.compare  LT, %arg2, %arg4,  UNSIGNED : (tensor<ui8>, tensor<ui8>) -> tensor<i1>
      %9 = stablehlo.and %7, %8 : tensor<i1>
      %10 = stablehlo.or %6, %9 : tensor<i1>
      %11 = stablehlo.select %6, %arg1, %arg3 : tensor<i1>, tensor<f32>
      %12 = stablehlo.select %10, %arg2, %arg4 : tensor<i1>, tensor<ui8>
      stablehlo.return %11, %12 : tensor<f32>, tensor<ui8>
    }
    return %3#1 : tensor<ui8>
  }
}
