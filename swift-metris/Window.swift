// tomocy

import Cocoa

class Window : NSWindow {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .miniaturizable, .closable],
            backing: .buffered,
            defer: false
        );

        title = "swift metris"

        contentView = View(frame: contentRect)

        NSLog("Window: Initialized")
        NSLog("Window: Frame: \(frame)")
    }
}
