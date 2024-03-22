// tomocy

import Cocoa

let app = NSApplication.shared

app.setActivationPolicy(.regular)

let delegate = AppDelegate.init()
app.delegate = delegate

let menu = AppMenu.init()
app.menu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
