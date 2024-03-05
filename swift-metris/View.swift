// tomocy

import Metal
import MetalKit

class View : MTKView {
    required init(coder: NSCoder) { super.init(coder: coder) }

    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        Log.debug("View: Initialized")
        Log.debug("View: GPU", with: [
            ("Name", device!.name),
        ])

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

        world = .init(size: frame.size)
    }

    private var pipeline: MTLRenderPipelineState?
    private var commandQueue: MTLCommandQueue?
    private var framePool: SemaphoricPool<MTLRenderFrame>?

    private var world: World2D?
}

extension View {
    private func makePipeline() -> MTLRenderPipelineState? {
        let desc = MTLRenderPipelineDescriptor.init()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        World2D.describe(to: desc, with: device!)

        return try? device!.makeRenderPipelineState(descriptor: desc)
    }

}

extension View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard var world = world else { return }

        let frame = framePool!.acquire()

        let command = commandQueue!.makeCommandBuffer()!

        do {
            let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!
            encoder.setRenderPipelineState(pipeline!)

            world.encode(with: encoder, in: frame)
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
        guard let world = world else { return }

        guard let chars = event.charactersIgnoringModifiers else { return }
        if chars.isEmpty {
            return
        }

        let command = chars.first!.lowercased()

        if let input = Metris.Input.Move.parse(command) {
            _ = world.metris.processInput(input)
            return
        }

        if let input = Metris.Input.Rotate.parse(command) {
            _ = world.metris.processInput(input)
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
