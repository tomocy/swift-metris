// tomocy

import Metal
import MetalKit

extension Engine {
    class View: MTKView {
        required init(coder: NSCoder) { super.init(coder: coder) }

        init(
            device: some MTLDevice,
            size: CGSize,
            target: some Target
        ) {
            super.init(
                frame: .init(
                    origin: .init(x: 0, y: 0),
                    size: size
                ),
                device: device
            )

            Engine.Log.log("View: Initialized", with: [
                ("Frame", frame.size.debugDescription),
            ])
            Engine.Log.log("View: GPU", with: [
                ("Name", device.name),
            ])

            delegate = self

            clearColor = .init(red: 0.0, green: 0.5, blue: 0.95, alpha: 1.0)
            sampleCount = 4
            colorPixelFormat = .bgra8Unorm_srgb
            depthStencilPixelFormat = .depth32Float

            shader = .init(device: device)
            self.target = target
        }

        private var shader: Shader.D3.Shader?
        private var target: Target?
    }
}

extension Engine.View: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let target = target else { return }

        let frame = shader!.acquire()

        let command = shader!.commandQueue.makeCommandBuffer()!

        target.tick(delta: 1 / .init(preferredFramesPerSecond))

        frame.shadow.encode(target, to: command)
        frame.mesh.encode(
            target,
            to: command, as: currentRenderPassDescriptor!,
            shadow: frame.shadow.target
        )

        command.present(currentDrawable!)

        command.addCompletedHandler { [weak self] _ in
            guard let self = self else { return }
            self.shader!.release()
        }
        command.commit()
    }
}

//extension Engine.View {
//    override func keyDown(with event: NSEvent) {
//        guard let world = world else { return }
//        world.keyDown(with: event)
//    }
//}

extension Engine.View {
    typealias Target = _EngineViewTarget
}

protocol _EngineViewTarget: Shader.D3.Shadow.Encodable, Shader.D3.Mesh.Encodable {
    func tick(delta: Float)
}
