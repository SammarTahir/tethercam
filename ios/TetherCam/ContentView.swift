import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var permission = CameraPermission()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "video.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("TetherCam")
                .font(.largeTitle.bold())

            statusView

            Text("Keep this app open while streaming. iOS pauses the camera in the background.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .onAppear { permission.request() }
        .onChange(of: scenePhase) { phase in
            if phase == .active { permission.refresh() }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch permission.status {
        case .authorized:
            Label("Camera access granted", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .notDetermined:
            Button("Allow camera access") { permission.request() }
                .buttonStyle(.borderedProminent)
        case .denied, .restricted:
            VStack(spacing: 12) {
                Label("Camera access is off", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        @unknown default:
            Text("Unknown camera permission state")
        }
    }
}
