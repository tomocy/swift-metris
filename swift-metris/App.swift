// tomocy

import Cocoa

class AppDelegate : NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("AppDelegate: Finished launching")

        window = Window(contentRect: NSRect(x: 0, y: 0, width: 500, height: 800))

        window!.orderFrontRegardless()
        window!.center()
    }

    private var window: NSWindow?
}
