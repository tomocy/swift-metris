// tomocy

import CoreGraphics
import Metal

extension Farm {
    class App: Engine.App.Delegate {}
}

extension Farm.App {
    convenience init() {
        let device = MTLCreateSystemDefaultDevice()!
        let size = CGSize.init(width: 800, height: 600)

        self.init(
            window: Engine.Window.init(
                title: "Metris",
                size: size,
                view: Engine.View.init(
                    device: device,
                    size: size,
                    target: Farm.World.init(
                        device: device,
                        resolution: .init(width: size.width * 2, height: size.height * 2)
                    )
                )
            )
        )
    }
}
