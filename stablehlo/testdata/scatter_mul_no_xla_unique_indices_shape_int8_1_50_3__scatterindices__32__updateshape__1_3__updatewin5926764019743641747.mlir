// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<32> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x50x3xi8>, tensor<1x3xi8>)
    %2 = call @expected() : () -> tensor<1x50x3xi8>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i8>, %arg1: tensor<i8>):
      %5 = stablehlo.multiply %arg0, %arg1 : tensor<i8>
      stablehlo.return %5 : tensor<i8>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x50x3xi8>, tensor<1xi32>, tensor<1x3xi8>) -> tensor<1x50x3xi8>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x50x3xi8>, tensor<1x50x3xi8>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x50x3xi8>, tensor<1x3xi8>) {
    %0 = stablehlo.constant dense<"0x000002FD0005000000FD00000100FD0301FDFF0102FD0301FFFCF8FF070002FDF900FDFF0000FE06FFFF0200040000000000020202040303080002FD000301FE04FD020000FF01FEFDFF000000FC020001FF000200FEFE0001FE0100020100FF000100050001FAFE060200040201FE0206FB00FC00FF01FF0201010101FB010001010000FE020300000000FD0000FFFEFFFE04FFFE01"> : tensor<1x50x3xi8>
    %1 = stablehlo.constant dense<[[-2, 1, 0]]> : tensor<1x3xi8>
    return %0, %1 : tensor<1x50x3xi8>, tensor<1x3xi8>
  }
  func.func private @expected() -> tensor<1x50x3xi8> {
    %0 = stablehlo.constant dense<"0x000002FD0005000000FD00000100FD0301FDFF0102FD0301FFFCF8FF070002FDF900FDFF0000FE06FFFF0200040000000000020202040303080002FD000301FE04FD020000FF01FEFDFF000000FC020001FF000200FEFE0001FE0100020100FF000100050001FAFE060200040201FE0206FB00FC00FF01FF0201010101FB010001010000FE020300000000FD0000FFFEFFFE04FFFE01"> : tensor<1x50x3xi8>
    return %0 : tensor<1x50x3xi8>
  }
}

