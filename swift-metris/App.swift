// tomocy

import Cocoa

class AppDelegate : NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("AppDelegate: Finished launching")

        window = Window.init(contentRect: .init(x: 0, y: 0, width: 400, height: 800))

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
            item.submenu = NSMenu.init()

            item.submenu!.items.append(
                NSMenuItem(
                    title: "Quit",
                    action: #selector(NSApplication.terminate(_:)),
                    keyEquivalent: "q"
                )
            )

            addItem(item)
        }
    }
}
