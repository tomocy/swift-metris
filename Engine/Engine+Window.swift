// tomocy

import Cocoa

extension Engine {
    class Window : NSWindow {
        init(contentRect: NSRect) {
            super.init(
                contentRect: contentRect,
                styleMask: [.titled, .miniaturizable, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            title = "Metris"
            contentView = Engine.View.init(frame: contentRect)
            makeFirstResponder(contentView)

            Engine.Log.log("Window: Initialized")
            Engine.Log.log("Window: Frame", with: [
                ("Range", "\(frame)"),
            ])
        }
    }
}
