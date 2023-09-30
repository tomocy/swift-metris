// tomocy

import Metal
import MetalKit

class View : MTKView, MTKViewDelegate {
    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        NSLog("View: Initialized")
        NSLog("View: GPU device: \(device!.name)")

        delegate = self
        clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        commandQueue = device!.makeCommandQueue()!
        pipeline = makePipeline()!

        metris = Metris(size: frame.size)
    }

    required init(coder: NSCoder) { super.init(coder: coder) }

    private func makePipeline() -> MTLRenderPipelineState? {
        let desc = MTLRenderPipelineDescriptor()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        Metris.describe(to: desc, with: device!)

        return try? device!.makeRenderPipelineState(descriptor: desc)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let metris = metris else { return }

        let command = commandQueue!.makeCommandBuffer()!

        let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!
        encoder.setRenderPipelineState(pipeline!)

        metris.encode(with: encoder)
        encoder.endEncoding()

        command.present(currentDrawable!)
        command.commit()
    }

    override func keyDown(with event: NSEvent) {
        if metris == nil {
            return
        }

        guard let chars = event.charactersIgnoringModifiers else { return }
        if chars.isEmpty {
            return
        }

        let delta = ({ (char: String) -> SIMD2<Int> in
            switch char {
            case "s":
                return SIMD2(0, -1)
            case "a":
                return SIMD2(-1, 0)
            case "d":
                return SIMD2(1, 0)
            default:
                return SIMD2(0, 0)
            }
        })(chars.first!.lowercased())

        metris!.moveMino(by: delta)
    }

    private var commandQueue: MTLCommandQueue?
    private var pipeline: MTLRenderPipelineState?

    private var metris: Metris?
}


