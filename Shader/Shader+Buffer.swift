// tomocy

import Metal

extension Shader {
    class Buffers {
        init(device: any MTLDevice) {
            self.device = device
            buffers = [:]
        }

        let device: any MTLDevice
        var buffers: [String: any MTLBuffer]
    }
}

extension Shader.Buffers {
    func take(at key: String, of size: Int, options: MTLResourceOptions) -> (any MTLBuffer)? {
        if !has(at: key, of: size) {
            buffers[key] = device.makeBuffer(length: size, options: options)
            buffers[key]?.label = key
        }

        return buffers[key]
    }

    func has(at key: String, of size: Int) -> Bool {
        return buffers.contains { buffer in
            return buffer.key == key
                && buffer.value.length == size
        }
    }
}

extension Shader.Buffers {
    struct Framed {
        let frame: Shader.Frame
        let buffers: Shader.Buffers
    }
}

extension Shader.Buffers.Framed {
    func take(at key: String, of size: Int, options: MTLResourceOptions) -> (any MTLBuffer)? {
        return buffers.take(
            at: "\(key)/\(frame.id)",
            of: size,
            options: options
        )
    }
}
