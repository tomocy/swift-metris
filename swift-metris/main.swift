import Foundation
import Cocoa

let app = NSApplication.shared;
let delegate = AppDelegate();
app.delegate = delegate;

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv);

class AppDelegate : NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("AppDelegate: Finished launching");
        
        window = NSWindow(
                   contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
                   styleMask: [.titled, .miniaturizable, .closable],
                   backing: .buffered,
                   defer: false
        )
        window!.title = "swift metris"
        
        window!.orderFrontRegardless();
        window!.center();
    }
    
    private var window: NSWindow?;
}
