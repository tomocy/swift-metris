// tomocy

import Metal
import MetalKit

class View: MTKView {
    required init(coder: NSCoder) { super.init(coder: coder) }

    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        Log.debug("View: Initialized", with: [
            ("Frame", frame.size.debugDescription),
        ])
        Log.debug("View: GPU", with: [
            ("Name", device!.name),
        ])

        delegate = self

        clearColor = .init(red: 0.0, green: 0.5, blue: 0.95, alpha: 1.0)
        sampleCount = 4
        colorPixelFormat = .bgra8Unorm_srgb
        depthStencilPixelFormat = .depth32Float

        shader = .init(device: device!)

        // This is the frame pool that is used to achieve "Triple Buffering",
        // or more precisely, "Triple Framing".
        framePool = .init(size: 3) { index in .init(id: index) }

        world = .init(device: device!, resolution: .init(drawableSize))
    }

    private var shader: Shader.D3.Shader?
    private var framePool: SemaphoricPool<MTLRenderFrame>?
    private var world: /* Farm.World? */ MetrisX.World?
}

extension View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let world = world else { return }

        _ = framePool!.acquire()

        let command = shader!.commandQueue.makeCommandBuffer()!

        // world.tick(delta: 1 / .init(preferredFramesPerSecond))

        shader!.shadow.encode(world, to: command)
        shader!.mesh.encode(
            world,
            to: command, as: currentRenderPassDescriptor!,
            shadow: shader!.shadow.target
        )

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
        world.engine.keyDown(with: event)
    }
}
