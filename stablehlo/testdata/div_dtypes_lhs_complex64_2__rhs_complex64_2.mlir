// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<2xcomplex<f32>>, tensor<2xcomplex<f32>>)
    %1 = call @expected() : () -> tensor<2xcomplex<f32>>
    %2 = stablehlo.divide %0#0, %0#1 : tensor<2xcomplex<f32>>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2xcomplex<f32>>, tensor<2xcomplex<f32>>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<2xcomplex<f32>>, tensor<2xcomplex<f32>>) {
    %0 = stablehlo.constant dense<[(2.58448601,-5.7651782), (0.464680344,-4.00015306)]> : tensor<2xcomplex<f32>>
    %1 = stablehlo.constant dense<[(2.14796209,-3.70222735), (2.28997922,2.68848014)]> : tensor<2xcomplex<f32>>
    return %0, %1 : tensor<2xcomplex<f32>>, tensor<2xcomplex<f32>>
  }
  func.func private @expected() -> tensor<2xcomplex<f32>> {
    %0 = stablehlo.constant dense<[(1.468070e+00,-0.15365693), (-0.776962637,-0.834638357)]> : tensor<2xcomplex<f32>>
    return %0 : tensor<2xcomplex<f32>>
  }
}
