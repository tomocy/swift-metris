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
        
        Vertex.describe(to: desc, buffer: 0, layout: 0)

        return desc;
    }

    func encode(with encoder: MTLRenderCommandEncoder) {
        let transform = Transform2D.orthogonal(size: size)
        transform.encode(with: encoder, at: 1)

        var primitive = IndexedPrimitive()

        do {
            var rect = Rectangle(
                size: CGSize(width: 200, height: 100)
            )
            rect.transform.translate.y = 100
            rect.transform.rotate(degree: 90)
            
            rect.append(to: &primitive)
        }

        do {
            var rect = Rectangle(
                size: CGSize(width: 200, height: 100)
            )
            rect.transform.translate.y = -100
            rect.transform.scale.x = 2
            
            rect.append(to: &primitive)
        }

        primitive.encode(with: encoder, at: 0)
    }

    let size: CGSize
}

struct Vertex {
    static func describe(to descriptor: MTLVertexDescriptor, buffer: Int, layout: Int) {
        var attr = 0
        var stride = 0
        
        // translate
        do {
            descriptor.attributes[attr].bufferIndex = buffer
            descriptor.attributes[attr].format = .float2
            descriptor.attributes[attr].offset = stride
            
            attr += 1
            
            stride += MemoryLayout<SIMD2<Float>>.size
            stride = align(stride, up: MemoryLayout<Vertex>.alignment)
        }
        
        // rotate
        do {
            descriptor.attributes[attr].bufferIndex = buffer
            descriptor.attributes[attr].format = .float
            descriptor.attributes[attr].offset = stride

            attr += 1
            
            stride += MemoryLayout<Float>.size
            stride = align(stride, up: MemoryLayout<Vertex>.alignment)
        }
        
        // scale
        do {
            descriptor.attributes[attr].bufferIndex = buffer
            descriptor.attributes[attr].format = .float2
            descriptor.attributes[attr].offset = stride
            
            attr += 1
            
            stride += MemoryLayout<SIMD2<Float>>.size
            stride = align(stride, up: MemoryLayout<Vertex>.alignment)
        }
        
        assert(stride == MemoryLayout<Vertex>.stride)
        descriptor.layouts[layout].stride = stride
    }
    
    func tranform(by transform: Transform2D) -> Self {
        return Self(
            translate: translate + transform.translate,
            rotate: rotate + transform.rotate,
            scale: scale * transform.scale
        )
    }
    
    let translate: SIMD2<Float>
    let rotate: Float
    let scale: SIMD2<Float>
};

extension Vertex {
    init(_ position: SIMD2<Float>) {
        translate = position
        rotate = 0
        scale = SIMD2(1, 1)
    }
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
        vertices.count - 1
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
                Vertex(SIMD2(-halfSize.x, halfSize.y)),
                Vertex(SIMD2(halfSize.x, halfSize.y)),
                Vertex(SIMD2(halfSize.x, -halfSize.y)),
                Vertex(SIMD2(-halfSize.x, -halfSize.y)),
            ].map({ v in v.tranform(by: transform) }),
            indices: [
                startIndex, startIndex + 1, startIndex + 2,
                startIndex + 2, startIndex + 3, startIndex,
            ]
        )
    }

    let size: CGSize
    var transform: Transform2D = Transform2D()
}

struct Transform2D {
    static func orthogonal(size: CGSize) -> Self {
        let half = SIMD2<Float>(Float(size.width), Float(size.height)) / 2;

        return orthogonal(
            top: half.y,
            bottom: -half.y,
            left: -half.x,
            right: half.x
        )
    }

    static func orthogonal(top: Float, bottom: Float, left: Float, right: Float) -> Self {
        return Transform2D(
            translate: SIMD2((left + right) / (left - right), (bottom + top) / (bottom - top)),
            scale: SIMD2(2 / (right - left), 2 / (top - bottom))
        )
    }
    
    mutating func rotate(degree: Float) {
        self.rotate = degree * .pi / 180
    }

    func apply() -> Matrix2D {
        let matrix = [
            Matrix2D.translate(translate),
            Matrix2D.rotate(rotate),
            Matrix2D.scale(scale),
        ]

        return Matrix2D(matrix.reduce(Matrix2D.identity, *))
    }
    
    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        let matrix = apply()
        matrix.encode(with: encoder, at: index)
    }

    var translate: SIMD2<Float> = SIMD2(0, 0)
    var rotate: Float = 0
    var scale: SIMD2<Float> = SIMD2(1, 1)
}

struct Matrix2D {
    typealias Raw = float3x3
    
    static func translate(_ delta: SIMD2<Float>) -> Raw {
        return Raw(
            rows: [
                SIMD3(1, 0, delta.x),
                SIMD3(0, 1, delta.y),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static func rotate(_ radian: Float) -> Raw {
        let s = sin(radian)
        let c = cos(radian)

        return Raw(
            rows: [
                SIMD3(c, -s, 0),
                SIMD3(s, c, 0),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static func scale(_ factor: SIMD2<Float>) -> Raw {
        return Raw(
            rows: [
                SIMD3(factor.x, 0, 0),
                SIMD3(0, factor.y, 0),
                SIMD3(0, 0, 1),
            ]
        )
    }

    static let identity: Raw = matrix_identity_float3x3

    init(_ raw: Raw = identity) {
        self.raw = raw
    }
    
    func encode(with encoder: MTLRenderCommandEncoder, at index: Int) {
        var bytes = raw;
        let buffer = (encoder.device.makeBuffer(
            bytes: &bytes,
            length: MemoryLayout<Raw>.stride,
            options: .storageModeShared
        ))!

        encoder.setVertexBuffer(buffer, offset: 0, index: index)
    }

    private var raw: Raw = identity
}

func align(_ n: Int, up alignment: Int) -> Int {
    return (n + alignment - 1) / alignment * alignment
}
