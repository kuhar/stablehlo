// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<0> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x125xui8>, tensor<1xui8>)
    %2 = call @expected() : () -> tensor<1x125xui8>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<ui8>, %arg1: tensor<ui8>):
      %5 = stablehlo.minimum %arg0, %arg1 : tensor<ui8>
      stablehlo.return %5 : tensor<ui8>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x125xui8>, tensor<1xi32>, tensor<1xui8>) -> tensor<1x125xui8>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x125xui8>, tensor<1x125xui8>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x125xui8>, tensor<1xui8>) {
    %0 = stablehlo.constant dense<"0x0502050003020503010203010202040002050701000000030600000000000100000301000503070101010101010303020202010200000000020600000100010202000301030007050503050300010202020002040001020002020306020200010001010002010202040000030402020101010301010200030002040204"> : tensor<1x125xui8>
    %1 = stablehlo.constant dense<1> : tensor<1xui8>
    return %0, %1 : tensor<1x125xui8>, tensor<1xui8>
  }
  func.func private @expected() -> tensor<1x125xui8> {
    %0 = stablehlo.constant dense<"0x0102050003020503010203010202040002050701000000030600000000000100000301000503070101010101010303020202010200000000020600000100010202000301030007050503050300010202020002040001020002020306020200010001010002010202040000030402020101010301010200030002040204"> : tensor<1x125xui8>
    return %0 : tensor<1x125xui8>
  }
}

