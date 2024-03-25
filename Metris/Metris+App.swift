// tomocy

import AppKit
import CoreGraphics
import Metal

extension Metris {
    class AppX: App.Engine.App.Delegate {}
}

extension Metris.AppX {
    convenience init() {
        let device = MTLCreateSystemDefaultDevice()!
        let size = CGSize.init(width: 800, height: 600)

        self.init(
            window: Engine.Window.init(
                title: "Metris",
                size: size,
                view: Metris.View.init(
                    device: device,
                    size: size,
                    target: Metris.World.init(
                        device: device,
                        resolution: .init(width: size.width * 2, height: size.height * 2)
                    )
                )
            )
        )
    }
}

extension Metris {
    class View: App.Engine.View {}
}

extension Metris.View {
    func target() -> Metris.World? { target as? Metris.World }
}

extension Metris.View {
    override func keyDown(with event: NSEvent) {
        guard let target = target() else { return }
        target.keyDown(with: event)
    }
}
