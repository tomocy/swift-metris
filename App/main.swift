// tomocy

import Cocoa
import Metal

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let (delegate, menu) = (
    // Farm.App.init(),
    Metris.AppX.init(),
    Engine.App.Menu.init()
)

app.delegate = delegate
app.menu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
