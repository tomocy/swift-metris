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

        delegate = self

        clearColor = .init(red: 0.25, green: 0.75, blue: 0.9, alpha: 1.0)
        depthStencilPixelFormat = .depth32Float

        shader = try! .init(
            device: device!,
            formats: .init(
                color: colorPixelFormat,
                depthStencil: depthStencilPixelFormat
            )
        )

        // This is the frame pool that is used to achieve "Triple Buffering",
        // or more precisely, "Triple Framing".
        framePool = .init(size: 3) { index in .init(id: index) }

        world = .init(device: device!)
    }

    private var shader: D3.XShader?
    private var framePool: SemaphoricPool<MTLRenderFrame>?
    private var world: D3.XWorld?
}

extension View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let world = world else { return }

        _ = framePool!.acquire()

        let command = shader!.commandQueue.makeCommandBuffer()!

        shader!.shadow(world, to: command)

        /* do {
            let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!
            defer { encoder.endEncoding() }

            encoder.setCullMode(.back)
            shader!.encode(&world, with: encoder)
        } */

        command.present(currentDrawable!)

        command.addCompletedHandler { [weak self] _ in
            guard let self = self else { return }
            self.framePool?.release()
        }
        command.commit()
    }
}

//extension View {
//    override func keyDown(with event: NSEvent) {
//        guard let world = world else { return }
//
//        guard let chars = event.charactersIgnoringModifiers else { return }
//        if chars.isEmpty {
//            return
//        }
//
//        let command = chars.first!.lowercased()
//
//        if let input = Metris.Input.Move.parse(command) {
//            _ = world.metris.processInput(input)
//            return
//        }
//
//        if let input = Metris.Input.Rotate.parse(command) {
//            _ = world.metris.processInput(input)
//        }
//    }
//}
//
//extension Metris.Input.Move {
//    static func parse(_ command: String) -> Self? {
//        switch command {
//        case "s":
//            return .down
//        case "a":
//            return .left
//        case "d":
//            return .right
//        default:
//            return nil
//        }
//    }
//}
//
//extension Metris.Input.Rotate {
//    static func parse(_ command: String) -> Self? {
//        switch command {
//        case "f":
//            return .being
//        default:
//            return nil
//        }
//    }
//}
