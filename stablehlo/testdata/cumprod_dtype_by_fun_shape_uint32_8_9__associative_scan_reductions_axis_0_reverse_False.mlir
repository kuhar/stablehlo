// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<8x9xui32>
    %1 = call @expected() : () -> tensor<8x9xui32>
    %2 = call @cumprod(%0) : (tensor<8x9xui32>) -> tensor<8x9xui32>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<8x9xui32>, tensor<8x9xui32>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<8x9xui32> {
    %0 = stablehlo.constant dense<[[0, 3, 5, 1, 4, 1, 0, 3, 4], [3, 9, 2, 0, 4, 0, 0, 0, 4], [0, 2, 0, 4, 1, 1, 1, 1, 3], [3, 2, 4, 2, 2, 4, 1, 1, 2], [1, 3, 2, 4, 0, 2, 1, 0, 4], [3, 2, 0, 1, 2, 8, 2, 0, 0], [0, 0, 0, 2, 0, 2, 1, 0, 1], [2, 7, 4, 4, 2, 0, 4, 2, 2]]> : tensor<8x9xui32>
    return %0 : tensor<8x9xui32>
  }
  func.func private @expected() -> tensor<8x9xui32> {
    %0 = stablehlo.constant dense<[[0, 3, 5, 1, 4, 1, 0, 3, 4], [0, 27, 10, 0, 16, 0, 0, 0, 16], [0, 54, 0, 0, 16, 0, 0, 0, 48], [0, 108, 0, 0, 32, 0, 0, 0, 96], [0, 324, 0, 0, 0, 0, 0, 0, 384], [0, 648, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0]]> : tensor<8x9xui32>
    return %0 : tensor<8x9xui32>
  }
  func.func private @cumprod(%arg0: tensor<8x9xui32>) -> tensor<8x9xui32> {
    %0 = "stablehlo.slice"(%arg0) {limit_indices = dense<[7, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<8x9xui32>) -> tensor<4x9xui32>
    %1 = "stablehlo.slice"(%arg0) {limit_indices = dense<[8, 9]> : tensor<2xi64>, start_indices = dense<[1, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<8x9xui32>) -> tensor<4x9xui32>
    %2 = stablehlo.multiply %0, %1 : tensor<4x9xui32>
    %3 = "stablehlo.slice"(%2) {limit_indices = dense<[3, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<4x9xui32>) -> tensor<2x9xui32>
    %4 = "stablehlo.slice"(%2) {limit_indices = dense<[4, 9]> : tensor<2xi64>, start_indices = dense<[1, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<4x9xui32>) -> tensor<2x9xui32>
    %5 = stablehlo.multiply %3, %4 : tensor<2x9xui32>
    %6 = "stablehlo.slice"(%5) {limit_indices = dense<[1, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<2x9xui32>) -> tensor<1x9xui32>
    %7 = "stablehlo.slice"(%5) {limit_indices = dense<[2, 9]> : tensor<2xi64>, start_indices = dense<[1, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<2x9xui32>) -> tensor<1x9xui32>
    %8 = stablehlo.multiply %6, %7 : tensor<1x9xui32>
    %9 = "stablehlo.slice"(%8) {limit_indices = dense<[0, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<1x9xui32>) -> tensor<0x9xui32>
    %10 = "stablehlo.slice"(%5) {limit_indices = dense<[2, 9]> : tensor<2xi64>, start_indices = dense<[2, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<2x9xui32>) -> tensor<0x9xui32>
    %11 = stablehlo.multiply %9, %10 : tensor<0x9xui32>
    %12 = "stablehlo.slice"(%5) {limit_indices = dense<[1, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<2x9xui32>) -> tensor<1x9xui32>
    %13 = stablehlo.concatenate %12, %11, dim = 0 : (tensor<1x9xui32>, tensor<0x9xui32>) -> tensor<1x9xui32>
    %14 = stablehlo.constant dense<0> : tensor<ui32>
    %15 = stablehlo.pad %13, %14, low = [0, 0], high = [1, 0], interior = [1, 0] : (tensor<1x9xui32>, tensor<ui32>) -> tensor<2x9xui32>
    %16 = stablehlo.constant dense<0> : tensor<ui32>
    %17 = stablehlo.pad %8, %16, low = [1, 0], high = [0, 0], interior = [1, 0] : (tensor<1x9xui32>, tensor<ui32>) -> tensor<2x9xui32>
    %18 = stablehlo.add %15, %17 : tensor<2x9xui32>
    %19 = "stablehlo.slice"(%18) {limit_indices = dense<[1, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<2x9xui32>) -> tensor<1x9xui32>
    %20 = "stablehlo.slice"(%2) {limit_indices = dense<[4, 9]> : tensor<2xi64>, start_indices = dense<[2, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<4x9xui32>) -> tensor<1x9xui32>
    %21 = stablehlo.multiply %19, %20 : tensor<1x9xui32>
    %22 = "stablehlo.slice"(%2) {limit_indices = dense<[1, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<4x9xui32>) -> tensor<1x9xui32>
    %23 = stablehlo.concatenate %22, %21, dim = 0 : (tensor<1x9xui32>, tensor<1x9xui32>) -> tensor<2x9xui32>
    %24 = stablehlo.constant dense<0> : tensor<ui32>
    %25 = stablehlo.pad %23, %24, low = [0, 0], high = [1, 0], interior = [1, 0] : (tensor<2x9xui32>, tensor<ui32>) -> tensor<4x9xui32>
    %26 = stablehlo.constant dense<0> : tensor<ui32>
    %27 = stablehlo.pad %18, %26, low = [1, 0], high = [0, 0], interior = [1, 0] : (tensor<2x9xui32>, tensor<ui32>) -> tensor<4x9xui32>
    %28 = stablehlo.add %25, %27 : tensor<4x9xui32>
    %29 = "stablehlo.slice"(%28) {limit_indices = dense<[3, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<4x9xui32>) -> tensor<3x9xui32>
    %30 = "stablehlo.slice"(%arg0) {limit_indices = dense<[8, 9]> : tensor<2xi64>, start_indices = dense<[2, 0]> : tensor<2xi64>, strides = dense<[2, 1]> : tensor<2xi64>} : (tensor<8x9xui32>) -> tensor<3x9xui32>
    %31 = stablehlo.multiply %29, %30 : tensor<3x9xui32>
    %32 = "stablehlo.slice"(%arg0) {limit_indices = dense<[1, 9]> : tensor<2xi64>, start_indices = dense<0> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<8x9xui32>) -> tensor<1x9xui32>
    %33 = stablehlo.concatenate %32, %31, dim = 0 : (tensor<1x9xui32>, tensor<3x9xui32>) -> tensor<4x9xui32>
    %34 = stablehlo.constant dense<0> : tensor<ui32>
    %35 = stablehlo.pad %33, %34, low = [0, 0], high = [1, 0], interior = [1, 0] : (tensor<4x9xui32>, tensor<ui32>) -> tensor<8x9xui32>
    %36 = stablehlo.constant dense<0> : tensor<ui32>
    %37 = stablehlo.pad %28, %36, low = [1, 0], high = [0, 0], interior = [1, 0] : (tensor<4x9xui32>, tensor<ui32>) -> tensor<8x9xui32>
    %38 = stablehlo.add %35, %37 : tensor<8x9xui32>
    return %38 : tensor<8x9xui32>
  }
}
