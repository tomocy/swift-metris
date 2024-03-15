// tomocy

import Metal
import MetalKit

class View: MTKView {
    required init(coder: NSCoder) { super.init(coder: coder) }

    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        Log.debug("View: Initialized")
        Log.debug("View: GPU", with: [
            ("Name", device!.name),
        ])

        world = D3.World.init(with: device!, for: frame.size)

        clearColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        delegate = self

        commandQueue = device!.makeCommandQueue()!
        pipelineStates = try! .init(view: self)

        // This is the frame pool that is used to achieve "Triple Buffering",
        // or more precisely, "Triple Framing".
        framePool = .init(
            size: 3,
            fill: { index in .init(id: index) }
        )
    }

    private var world: D3.World?

    private var commandQueue: MTLCommandQueue?
    private var pipelineStates: MTLPipelineStates?
    private var framePool: SemaphoricPool<MTLRenderFrame>?
}

extension View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let world = world else { return }

        let frame = framePool!.acquire()

        let command = commandQueue!.makeCommandBuffer()!

        do {
            let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!
            defer { encoder.endEncoding() }

            encoder.setRenderPipelineState(pipelineStates!.render)

            world.encode(with: encoder, in: frame)
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

extension View {
    fileprivate struct MTLPipelineStates {
        var render: MTLRenderPipelineState
    }
}

extension View.MTLPipelineStates {
    init(view: View) throws {
        render = try Self.make(in: view)
    }
}

extension View.MTLPipelineStates {
    static func make(in view: View) throws -> MTLRenderPipelineState {
        let desc: MTLRenderPipelineDescriptor = .init()

        do {
            let attachment = desc.colorAttachments[0]!
            attachment.pixelFormat = view.colorPixelFormat
        }

        do {
            let lib = view.device!.makeDefaultLibrary()!

            desc.vertexFunction = lib.makeFunction(name: "D3::vertexMain")!
            desc.fragmentFunction = lib.makeFunction(name: "D3::fragmentMain")!
        }

        return try view.device!.makeRenderPipelineState(descriptor: desc)
    }
}
