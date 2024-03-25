// tomocy

import Cocoa

extension Engine {
    enum App {}
}

extension Engine.App {
    class Delegate: NSObject {
        init(window: NSWindow) {
            self.window = window
        }

        private var window: NSWindow
    }
}

extension Engine.App.Delegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Engine.Log.log("App: Launched")

        window.makeKeyAndOrderFront(notification)
        window.center()

        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

extension Engine.App {
    class Menu: NSMenu {
        required init(coder: NSCoder) { super.init(coder: coder) }

        override init(title: String) {
            super.init(title: title)

            do {
                let item = NSMenuItem.init()
                item.submenu = .init()

                item.submenu!.items.append(
                    .init(
                        title: "Quit",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q"
                    )
                )

                addItem(item)
            }
        }
    }
}
