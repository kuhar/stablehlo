// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[[0, 1], [2, 3]], [[4, 0], [1, 2]]]> : tensor<2x2x2xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xi16>, tensor<5x2x2xi16>)
    %2 = call @expected() : () -> tensor<5x6x7xi16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i16>, %arg1: tensor<i16>):
      stablehlo.return %arg1 : tensor<i16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1, 2], scatter_dims_to_operand_dims = [1, 2], index_vector_dim = 2>, unique_indices = true} : (tensor<5x6x7xi16>, tensor<2x2x2xi32>, tensor<5x2x2xi16>) -> tensor<5x6x7xi16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xi16>, tensor<5x6x7xi16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xi16>, tensor<5x2x2xi16>) {
    %0 = stablehlo.constant dense<"0x0100000000000100FDFF00000000FDFFFFFF0000FCFFFEFF000000000400F8FF0400FDFF000000000700FFFFFEFF030000000000FCFFFCFF0200FEFF03000400F5FF0100000000000200FEFF00000400000000000300FDFFFFFF000002000100FFFF0000FEFF030002000000020005000600000000000000FDFF0000000002000000FEFF0800FCFF00000000020001000000FEFFFFFFFFFF0000FCFF0100010000000000FFFFFFFFFDFF0000FDFF020001000300FCFF0000FCFF0300FDFFFDFF040000000000000000000000FDFFFCFFFEFFFBFF00000100FEFF02000000FDFF0000040004000300FFFF0400050000000400FFFFFFFF01000400FCFFFFFFFCFFFEFF02000000FFFF0200FDFFFDFF03000000FEFFFFFF0000FDFF00000400FDFF0100FEFF0000010002000400FEFF0000FFFF0200030002000600FDFF010001000200FFFF000000000300030001000200FCFFFEFFFFFFFFFF0400010000000000FFFF01000300FCFF00000600FFFF01000000FEFF0000FCFFFCFFFFFFFBFFFCFF01000100FFFFFEFF0200000000000300F8FFFEFF0100FCFFFFFF0300FCFFFFFFFFFFFBFF"> : tensor<5x6x7xi16>
    %1 = stablehlo.constant dense<[[[0, 6], [-1, -1]], [[0, 0], [4, -3]], [[3, 0], [-5, 0]], [[-2, -4], [0, 0]], [[1, 3], [0, 0]]]> : tensor<5x2x2xi16>
    return %0, %1 : tensor<5x6x7xi16>, tensor<5x2x2xi16>
  }
  func.func private @expected() -> tensor<5x6x7xi16> {
    %0 = stablehlo.constant dense<"0x0100000000000100FDFF00000000FDFFFFFFFFFFFCFFFEFF000000000400F8FF04000600000000000700FFFFFEFF030000000000FCFFFCFFFFFFFEFF03000400F5FF0100000000000200FEFF000004000000000003000000FFFF000002000100FFFF0000FEFFFDFF02000000020005000600000000000000FDFF0000000002000000FEFF0800FCFF00000000040001000000FEFFFFFFFFFF0000FCFF0100010000000000FFFFFFFFFDFF0300FDFF020001000300FCFF0000FCFF0000FDFFFDFF040000000000000000000000FDFFFCFFFEFFFBFF00000100FEFF02000000FDFFFBFF040004000300FFFF0400050000000400FFFFFFFF01000400FCFFFFFFFEFFFEFF02000000FFFF0200FDFFFDFF00000000FEFFFFFF0000FDFF00000400FCFF0100FEFF0000010002000400FEFF0000FFFF0200000002000600FDFF010001000200FFFF000000000300030001000200FCFF0100FFFFFFFF0400010000000000FFFF00000300FCFF00000600FFFF0100000003000000FCFFFCFFFFFFFBFFFCFF01000100FFFFFEFF0000000000000300F8FFFEFF0100FCFFFFFF0300FCFFFFFFFFFFFBFF"> : tensor<5x6x7xi16>
    return %0 : tensor<5x6x7xi16>
  }
}

