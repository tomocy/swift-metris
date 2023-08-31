import Foundation
import Cocoa
import Metal
import MetalKit

let app = NSApplication.shared;
let delegate = AppDelegate();
app.delegate = delegate;

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv);

class AppDelegate : NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("AppDelegate: Finished launching")

        window = Window(contentRect: NSRect(x: 0, y: 0, width: 640, height: 640))

        window.orderFrontRegardless()
        window.center()
    }

    private var window: NSWindow!;
}

class Window : NSWindow {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .miniaturizable, .closable],
            backing: .buffered,
            defer: false
        );

        title = "swift metris"

        contentView = View(frame: frame)

        NSLog("Window: Initialized");
        NSLog("Window: Frame: \(frame)")
    }
}

class View : MTKView, MTKViewDelegate {
    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        NSLog("View: Initialized")
        NSLog("View: GPU device: \(device!.name)")

        delegate = self
        clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

        commandQueue = device!.makeCommandQueue()!
        pipeline = makePipeline()
        vertexBuffer = makeVertexBuffer()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func makePipeline() -> MTLRenderPipelineState {
        let desc = MTLRenderPipelineDescriptor()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        let lib = device!.makeDefaultLibrary()
        assert(lib != nil)

        desc.vertexFunction = lib!.makeFunction(name: "vertex_main")
        NSLog("Vertex function: \(desc.vertexFunction!.name)")

        desc.fragmentFunction = lib!.makeFunction(name: "fragment_main")
        NSLog("Fragment function: \(desc.fragmentFunction!.name)")

        return try! device!.makeRenderPipelineState(descriptor: desc)
    }

    private func makeVertexBuffer() -> MTLBuffer {
        var positions = [
            SIMD2<Float>(-0.8, 0.4),
            SIMD2<Float>(0.4, -0.8),
            SIMD2<Float>(0.8, 0.8),
        ]

        return (device?.makeBuffer(
            bytes: &positions,
            length: MemoryLayout<SIMD2<Float>>.stride * positions.count,
            options: .storageModeShared
        ))!
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        let command = commandQueue.makeCommandBuffer()!

        let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        encoder.endEncoding()

        command.present(currentDrawable!)

        command.commit()
    }

    private var commandQueue: MTLCommandQueue!
    private var pipeline: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
}
