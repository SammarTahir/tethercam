import SwiftUI
import os

let appLog = Logger(subsystem: "app.tethercam", category: "app")

@main
struct TetherCamApp: App {
    init() {
        appLog.info("TetherCam launched")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
