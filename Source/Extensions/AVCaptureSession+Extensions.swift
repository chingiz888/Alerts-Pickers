import Foundation
import AVFoundation

public extension AVCaptureSession {
    
    @discardableResult public func setPresetsAlertnately(_ presets: [Preset]) -> Bool {
        for preset in presets {
            if canSetSessionPreset(preset) {
                sessionPreset = preset
                return true
            }
        }
        return false
    }
    
}
