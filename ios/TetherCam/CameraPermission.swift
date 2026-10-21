import AVFoundation
import os

private let log = Logger(subsystem: "app.tethercam", category: "permission")

/// Tracks and requests camera access. Video only: the microphone is never requested.
@MainActor
final class CameraPermission: ObservableObject {
    @Published private(set) var status = AVCaptureDevice.authorizationStatus(for: .video)

    func refresh() {
        status = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func request() {
        guard status == .notDetermined else { return }
        AVCaptureDevice.requestAccess(for: .video) { granted in
            log.info("Camera access granted: \(granted, privacy: .public)")
            Task { @MainActor in self.refresh() }
        }
    }
}
