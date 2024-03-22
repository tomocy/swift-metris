// tomocy

import CoreGraphics
import Metal

enum Texture {}

extension Texture {
    struct Source {
        var raw: Raw
    }
}

extension Texture.Source {
    typealias Raw = MTLTexture
}

extension Texture.Source {
    init(_ raw: Raw) {
        self.raw = raw
    }

    init?(_ raw: Raw?) {
        guard let raw = raw else { return nil }
        self.init(raw)
    }
}

extension Texture.Source: Equatable {
    static func ==(left: Self, right: Self) -> Bool {
        return left.raw === right.raw
    }
}

extension Texture.Source: Identifiable {
    var id: ObjectIdentifier { .init(raw) }
}

extension Texture.Source: Hashable {
    var hashValue: Int { id.hashValue }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Texture {
    enum Sources {}
}

extension Texture.Sources {
    struct Color {}
}

extension Texture.Sources.Color {
    private struct BGRA {
        init(_ color: CGColor) {
            let factor: CGFloat = 255

            blue = .init(color.blue * factor)
            green = .init(color.green * factor)
            red = .init(color.red * factor)
            alpha = .init(color.alpha * factor)
        }

        var blue: UInt8
        var green: UInt8
        var red: UInt8
        var alpha: UInt8
    }

    static func load(_ color: CGColor, with device: MTLDevice) -> Texture.Source? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: 1, height: 1,
            mipmapped: false
        )

        let texture = device.makeTexture(descriptor: desc)

        let pixels = [BGRA].init(repeating: .init(color), count: desc.width * desc.height)
        pixels.withUnsafeBytes { bytes in
            texture?.replace(
                region: .init(
                    origin: .init(x: 0, y: 0, z: 0),
                    size: .init(width: desc.width, height: desc.height, depth: 1)
                ),
                mipmapLevel: 0,
                withBytes: bytes.baseAddress!,
                bytesPerRow: bytes.count / desc.width
            )
        }

        return .init(texture)
    }
}

extension Texture {
    struct Reference<P: Dimension.Precision> {
        var coordinate: SIMD2<Precision> = .init(0, 0)
    }
}

extension Texture.Reference {
    typealias Precision = P
}
