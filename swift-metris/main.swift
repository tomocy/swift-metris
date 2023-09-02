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

        window = Window(contentRect: NSRect(x: 0, y: 0, width: 500, height: 800))

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
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func makePipeline() -> MTLRenderPipelineState {
        let desc = MTLRenderPipelineDescriptor()

        desc.colorAttachments[0].pixelFormat = colorPixelFormat

        let lib = (device!.makeDefaultLibrary())!

        desc.vertexFunction = lib.makeFunction(name: "vertex_main")
        NSLog("Vertex function: \(desc.vertexFunction!.name)")

        desc.fragmentFunction = lib.makeFunction(name: "fragment_main")
        NSLog("Fragment function: \(desc.fragmentFunction!.name)")

        return try! device!.makeRenderPipelineState(descriptor: desc)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor!)!

        encoder.setRenderPipelineState(pipeline)

        let transform = Transform()
        transform.apply(Matrix2D.orthogonal(size: SIMD2(Float(frame.size.width), Float(frame.size.height))))
        transform.encode(with: encoder, at: 1)

        let rect = Rectangle()
        rect.encode(with: encoder, at: 0)

        encoder.endEncoding()

        command.present(currentDrawable!)

        command.commit()
    }

    private var commandQueue: MTLCommandQueue!
    private var pipeline: MTLRenderPipelineState!
}

class Rectangle {
    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        var vertices: [SIMD2<Float>] = [
            SIMD2(-100, 100),
            SIMD2(100, 100),
            SIMD2(100, -100),
            SIMD2(-100, -100),
        ];
        var indices: [UInt16] = [
            0, 1, 2,
            2, 3, 0,
        ]

        let vertexBuffer = (encoder.device.makeBuffer(
            bytes: &vertices,
            length: MemoryLayout<SIMD2<Float>>.stride * vertices.count,
            options: .storageModeShared
        ))!
        let indexBuffer = (encoder.device.makeBuffer(
            bytes: &indices,
            length: MemoryLayout<UInt16>.stride * indices.count,
            options: .storageModeShared
        ))!

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }
}

class Transform {
    func apply(_ matrix: float4x4) {
        value = simd_mul(value, matrix)
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        let buffer = (encoder.device.makeBuffer(
            bytes: &value,
            length: MemoryLayout<float4x4>.stride,
            options: .storageModeShared
        ))!

        encoder.setVertexBuffer(buffer, offset: 0, index: index)
    }

    private var value: float4x4 = matrix_identity_float4x4;
}

class Matrix2D {
    static func orthogonal(size: SIMD2<Float>) -> float4x4 {
        let half = size / 2;
        return orthogonal(
            top: half.y,
            bottom: -half.y,
            left: -half.x,
            right: half.x
        )
    }

    static func orthogonal(top: Float, bottom: Float, left: Float, right: Float) -> float4x4 {
        let t = translate(SIMD2(
            (left + right) / (left - right),
            (bottom + top) / (bottom - top)
        ))
        let s = scale(SIMD2(
            2 / (right - left),
            2 / (top - bottom)
        ))

        return simd_mul(s, t)
    }

    static func translate(_ delta: SIMD2<Float>) -> float4x4 {
        // 1 0 0 Tx
        // 0 1 0 Ty
        // 0 0 1 0
        // 0 0 0 1

        var m = matrix_identity_float4x4
        m.columns.3.x = delta.x
        m.columns.3.y = delta.y

        return m
    }

    static func scale(_ factor: SIMD2<Float>) -> float4x4 {
        // Sx 0  0 0
        // 0  Sy 0 0
        // 0  0  1 0
        // 0  0  0 1

        var m = matrix_identity_float4x4
        m.columns.0.x = factor.x;
        m.columns.1.y = factor.y;

        return m
    }
}
