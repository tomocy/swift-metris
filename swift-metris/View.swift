// tomocy

import Metal
import MetalKit

class View : MTKView, MTKViewDelegate {
    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        NSLog("View: Initialized")
        NSLog("View: GPU device: \(device!.name)")

        delegate = self
        commandQueue = device!.makeCommandQueue()!
        pipeline = makePipeline()

        clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        metris = Metris(size: frame.size)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func makePipeline() -> MTLRenderPipelineState {
        let desc = MTLRenderPipelineDescriptor()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        Metris.describe(to: desc, with: device!)

        return try! device!.makeRenderPipelineState(descriptor: desc)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        let command = commandQueue!.makeCommandBuffer()!
        let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!

        encoder.setRenderPipelineState(pipeline!)

        do {
            metris!.process()
            metris!.encode(with: encoder)
        }

        encoder.endEncoding()

        command.present(currentDrawable!)
        command.commit()
    }

    private var commandQueue: MTLCommandQueue?
    private var pipeline: MTLRenderPipelineState?

    private var metris: Metris?
}


