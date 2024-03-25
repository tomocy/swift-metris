// tomocy

import Cocoa

let app = NSApplication.shared

app.setActivationPolicy(.regular)

let size = CGSize.init(width: 800, height: 600)
let delegate = Engine.App.Delegate.init(
    window: Engine.Window.init(
        title: "Metris",
        size: size,
        view: Engine.View.init(size: size)
    )
)
app.delegate = delegate

let menu = Engine.App.Menu.init()
app.menu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
