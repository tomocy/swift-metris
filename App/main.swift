// tomocy

import Cocoa

let app = NSApplication.shared

app.setActivationPolicy(.regular)

let delegate = Engine.App.Delegate.init()
app.delegate = delegate

let menu = Engine.App.Menu.init()
app.menu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
