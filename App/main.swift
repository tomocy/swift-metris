// tomocy

import Cocoa
import Metal

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let delegate = Farm.App.init()
app.delegate = delegate

let menu = Engine.App.Menu.init()
app.menu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
