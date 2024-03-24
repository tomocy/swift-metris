// tomocy

import CoreGraphics
import Metal

extension Engine {
    enum Texture {}
}

extension Engine.Texture {
    private struct BGRA8UNormalized {
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

    static func generate(_ color: CGColor, with device: any MTLDevice) -> (any MTLTexture)? {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: 1, height: 1,
            mipmapped: false
        )

        let texture = device.makeTexture(descriptor: desc)

        let pixels = [BGRA8UNormalized].init(repeating: .init(color), count: desc.width * desc.height)
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

        return texture
    }
}
