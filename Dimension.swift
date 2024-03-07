// tomocy

import simd

protocol DimensionalPrecision: Encodable, Decodable, FloatingPoint, SIMDScalar {}

extension Float: DimensionalPrecision {}

enum D3 {}

extension D3 {
    typealias Storage = SIMD3
}
