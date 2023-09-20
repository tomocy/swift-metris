// tomocy

import Metal

struct Vertex {
    static func describe(to descriptor: MTLVertexDescriptor, buffer: Int, layout: Int) {
        let describe = { (attr: Int, stride: Int, format: MTLVertexFormat) -> Int in
            descriptor.attributes[attr].bufferIndex = buffer
            descriptor.attributes[attr].format = format
            descriptor.attributes[attr].offset = stride

            var stride = stride
            switch format {
            case .float:
                stride += MemoryLayout<Float>.size
            case .float2:
                stride += MemoryLayout<SIMD2<Float>>.size
            default:
                stride += 0
            }
            stride = align(stride, up: MemoryLayout<Vertex>.alignment)

            return stride
        }

        var stride = 0

        // position
        stride = describe(0, stride, .float2)

        // translate
        stride = describe(1, stride, .float2)

        // rotate
        stride = describe(2, stride, .float)

        // scale
        stride = describe(3, stride, .float2)

        descriptor.layouts[layout].stride = stride
        assert(descriptor.layouts[layout].stride == MemoryLayout<Vertex>.stride)
    }

    func tranform(by transform: Transform2D) -> Self {
        return Self(
            position: position,
            translate: translate + transform.translate,
            rotate: rotate + transform.rotate,
            scale: scale * transform.scale
        )
    }

    let position: SIMD2<Float>
    let translate: SIMD2<Float>
    let rotate: Float
    let scale: SIMD2<Float>
};

extension Vertex {
    init(_ position: SIMD2<Float>) {
        self.position = position
        translate = SIMD2(0, 0)
        rotate = 0
        scale = SIMD2(1, 1)
    }
}

