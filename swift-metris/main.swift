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
        
        window = Window(contentRect: NSRect(x: 0, y: 0, width: 480, height: 270))
        
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
        delegate = self;
        
        commandQueue = device!.makeCommandQueue()!
        
        clearColor = MTLClearColorMake(0, 0.5, 1, 1)
        
        NSLog("View: Initialized")
        NSLog("View: GPU device: \(device!.name)")
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        let command = commandQueue.makeCommandBuffer()!
        
        guard let desc = currentRenderPassDescriptor else {
            NSLog("View: No render pass descriptor available")
            NSLog("View: Skipped frame")
            return
        }
        
        let encoder = command.makeRenderCommandEncoder(descriptor: desc)!
        encoder.endEncoding()
        
        command.present(currentDrawable!)
        
        command.commit()
    }
    
    private var commandQueue: MTLCommandQueue!
}
