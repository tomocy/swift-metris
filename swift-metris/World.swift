// tomocy

import CoreGraphics
import Metal

protocol World: MTLRenderPipelineDescriable, MTLFrameRenderCommandEncodable {
    var metris: Metris { get }
}

class World2D: World {
    init(size: CGSize) {
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            camera = .init(
                projection: .orthogonal(
                    top: halfSize.y, bottom: -halfSize.y,
                    left: -halfSize.x, right: halfSize.x
                ),
                transform: .init(
                    translate: halfSize
                )
            )
        }

        metris = .init(size: size)
        metris.start()
    }

    var camera: Camera2D
    var metris: Metris
}

extension World2D: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "World2D::shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}


extension World2D: MTLFrameRenderCommandEncodable {
    func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(with: encoder, at: 0, in: frame)
        metris.encode(with: encoder, at: 1, in: frame)
    }
}

class World3D: World {
    init(size: CGSize) {
        do {
            let halfSize = SIMD2<Float>.init(size) / 2
            let halfDepth = halfSize.max()
            camera = .init(
                projection: .orthogonal(
                    top: halfSize.y, bottom: -halfSize.y,
                    left: -halfSize.x, right: halfSize.x,
                    near: -halfDepth, far: halfDepth
                )
            )
        }

        metris = .init(size: size)
    }

    var camera: Camera3D
    var metris: Metris
}

extension World3D: MTLRenderPipelineDescriable {
    func describe(with device: MTLDevice, to descriptor: MTLRenderPipelineDescriptor) {
        let lib = device.makeDefaultLibrary()!

        descriptor.vertexFunction = lib.makeFunction(name: "World3D::shadeVertex")!
        descriptor.fragmentFunction = lib.makeFunction(name: "shadeFragment")!
    }
}

extension World3D: MTLFrameRenderCommandEncodable {
    func encode(with encoder: MTLRenderCommandEncoder, in frame: MTLRenderFrame) {
        camera.encode(
            with: encoder,
            to: encoder.device.makeBuffer(
                length: type(of: camera.state).stride,
                options: .storageModeShared
            )!,
            at: 0
        )

        do {
            var primitive = IndexedPrimitive3D.init()
            do {
                var cube = Cube(
                    size: .init(50, 50, 50),
                    color: .init(.random())
                )

                cube.transform.rotate(
                    with: .init(0, 0, Angle(degree: 45).inRadian())
                )

                cube.append(to: &primitive)
            }

            primitive.encode(
                with: encoder,
                to: .init(
                    data: encoder.device.makeBuffer(
                        length: primitive.vertices.size,
                        options: .storageModeShared
                    )!,
                    index: encoder.device.makeBuffer(
                        length: primitive.indices.size,
                        options: .storageModeShared
                    )!
                ),
                at: 1
            )
        }
    }
}
