// tomocy

import Cocoa

class Window : NSWindow {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .miniaturizable, .closable],
            backing: .buffered,
            defer: false
        )

        title = "swift metris"
        contentView = View.init(frame: contentRect)
        makeFirstResponder(contentView)

        NSLog("Window: Initialized")
        NSLog("Window: Frame: \(frame)")
    }
}
