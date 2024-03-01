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

        Log.debug("Window: Initialized")
        Log.debug("Window: Frame", with: [
            ("Range", "\(frame)"),
        ])
    }
}
