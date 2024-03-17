// tomocy

import simd

enum Dimension {
    typealias Precision = _DimensionPrecision
}

protocol _DimensionPrecision: Encodable, Decodable, BinaryFloatingPoint, SIMDScalar {}

extension Float: Dimension.Precision {}

enum D3 {}

extension D3 {
    typealias Storage = SIMD3
    typealias Matrix = float4x4
}
