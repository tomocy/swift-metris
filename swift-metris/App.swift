// tomocy

import Cocoa

class AppDelegate : NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.debug("App: Launched")

        window = Window.init(
            contentRect: .init(
                x: 0, y: 0,
                width: 800, height: 600
            )
        )

        window!.makeKeyAndOrderFront(notification)
        window!.center()

        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    private var window: NSWindow?
}

class AppMenu : NSMenu {
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
