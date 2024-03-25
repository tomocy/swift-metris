// tomocy

import Cocoa

extension Engine {
    class Window: NSWindow {
        init(title: String, size: CGSize, view: NSView) {
            super.init(
                contentRect: .init(
                    origin: .init(x: 0, y: 0),
                    size: size
                ),
                styleMask: [.titled, .miniaturizable, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            self.title = title
            contentView = view
            makeFirstResponder(contentView)

            Engine.Log.log("Window: Initialized")
            Engine.Log.log("Window: Frame", with: [
                ("Range", "\(frame)"),
            ])
        }
    }
}
