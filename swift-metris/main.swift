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
        
        desc.vertexDescriptor = RenderTarget.describe()
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

        let target = RenderTarget(size: frame.size)
        target.encode(with: encoder)

        encoder.endEncoding()

        command.present(currentDrawable!)

        command.commit()
    }

    private var commandQueue: MTLCommandQueue!
    private var pipeline: MTLRenderPipelineState!
}

struct RenderTarget {
    static func describe() -> MTLVertexDescriptor {
        let desc = MTLVertexDescriptor();
        
        // Vertex
        // - position
        desc.attributes[0].bufferIndex = 0;
        desc.attributes[0].format = .float2;
        desc.attributes[0].offset = 0;
        
        desc.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride;
        
        return desc;
    }
    
    func encode(with encoder: MTLRenderCommandEncoder) {
        let transform = Transform(
            value: Matrix2D.orthogonal(size: SIMD2(Float(size.width), Float(size.height)))
        )
        transform.encode(with: encoder, at: 1)

        var primitive = IndexedPrimitive()
        
        let rect = Rectangle(size: CGSize(width: 200, height: 100))
        rect.append(to: &primitive)
        
        primitive.encode(with: encoder, at: 0)
    }

    let size: CGSize
}

struct IndexedPrimitive {
    mutating func append(vertices: [Vertex], indices: [UInt16]) {
        self.vertices += vertices
        self.indices += indices
    }
    
    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        let vertexBuffer = (encoder.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Vertex>.stride * vertices.count,
            options: .storageModeShared
        ))!
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
        
        let indexBuffer = (encoder.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.stride * indices.count,
            options: .storageModeShared
        ))!
        encoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }
    
    var lastIndex: Int {
        indices.count - 1
    }
    
    private var vertices: [Vertex] = []
    private var indices: [UInt16] = []
}

struct Rectangle {
    func append(to primitive: inout IndexedPrimitive) {
        let halfSize = SIMD2<Float>(Float(size.width / 2), Float(size.height / 2))
        
        let startIndex = UInt16(primitive.lastIndex + 1)
    
        
        primitive.append(
            vertices: [
                Vertex(position: SIMD2(-halfSize.x, halfSize.y)),
                Vertex(position: SIMD2(halfSize.x, halfSize.y)),
                Vertex(position: SIMD2(halfSize.x, -halfSize.y)),
                Vertex(position: SIMD2(-halfSize.x, -halfSize.y)),
            ],
            indices: [
                startIndex, startIndex + 1, startIndex + 2,
                startIndex + 2, startIndex + 3, startIndex,
            ]
        )
    }
    
    let size: CGSize
}

struct Vertex {
    let position: SIMD2<Float>
};


struct Transform {
    init(value: float4x4) {
        self.value = value;
    }

    mutating func apply(_ matrix: float4x4) {
        value = simd_mul(value, matrix)
    }

    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        var bytes = value;
        let buffer = (encoder.device.makeBuffer(
            bytes: &bytes,
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

        return simd_mul(t, s)
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
