// tomocy

import Metal
import MetalKit

class View : MTKView {
    required init(coder: NSCoder) { super.init(coder: coder) }

    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        NSLog("View: Initialized")
        NSLog("View: GPU device: \(device!.name)")

        clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        delegate = self
        pipeline = makePipeline()!
        commandQueue = device!.makeCommandQueue()!

        // This is the frame pool that is used to achieve "Triple Buffering",
        // or more precisely, "Triple Framing".
        framePool = .init(
            size: 3,
            fill: { index in .init(id: index) }
        )

        metris = Metris(size: frame.size)
        metris!.start()
    }

    private var pipeline: MTLRenderPipelineState?
    private var commandQueue: MTLCommandQueue?
    private var framePool: SemaphoricPool<MTLRenderFrame>?

    private var metris: Metris?
}

extension View {
    private func makePipeline() -> MTLRenderPipelineState? {
        let desc = MTLRenderPipelineDescriptor.init()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        Metris.describe(to: desc, with: device!)

        return try? device!.makeRenderPipelineState(descriptor: desc)
    }

}

extension View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let metris = metris else { return }

        let frame = framePool!.acquire()

        let command = commandQueue!.makeCommandBuffer()!

        do {
            let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!
            encoder.setRenderPipelineState(pipeline!)

            metris.encode(with: encoder, in: frame)
            encoder.endEncoding()
        }

        command.present(currentDrawable!)

        command.addCompletedHandler { [weak self] _ in
            guard let self = self else { return }
            self.framePool?.release()
        }
        command.commit()
    }
}

extension View {
    override func keyDown(with event: NSEvent) {
        if metris == nil {
            return
        }

        guard let chars = event.charactersIgnoringModifiers else { return }
        if chars.isEmpty {
            return
        }

        let command = chars.first!.lowercased()

        if let input = Metris.Input.Move.parse(command) {
            _ = metris!.processInput(input)
            return
        }

        if let input = Metris.Input.Rotate.parse(command) {
            _ = metris!.processInput(input)
        }
    }
}

extension Metris.Input.Move {
    static func parse(_ command: String) -> Self? {
        switch command {
        case "s":
            return .down
        case "a":
            return .left
        case "d":
            return .right
        default:
            return nil
        }
    }
}

extension Metris.Input.Rotate {
    static func parse(_ command: String) -> Self? {
        switch command {
        case "f":
            return .being
        default:
            return nil
        }
    }
}
