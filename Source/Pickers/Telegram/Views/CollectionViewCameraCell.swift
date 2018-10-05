import Foundation
import UIKit
import AVFoundation

public typealias CollectionViewCameraCell = CollectionViewCustomContentCell<CameraView>

public class CameraView: UIView {
    
    private var videoLayer: AVCaptureVideoPreviewLayer? = nil
    
    public func setup(stream: Camera.PreviewStream) {
        guard  !isRepresentingStream(stream) else {
            return
        }
        
        self.reset()
        
        let newVideoLayer = AVCaptureVideoPreviewLayer.init(session: stream.session)
        
        layer.addSublayer(newVideoLayer)
        videoLayer = newVideoLayer
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = videoLayer {
            layer.frame = self.bounds
        }
    }
    
    public func reset() {
        self.videoLayer?.removeFromSuperlayer()
        self.videoLayer = nil
    }
    
    public func isRepresentingStream(_ stream: Camera.PreviewStream) -> Bool {
        if let layer = videoLayer, let session = layer.session {
            return session === stream.session
        }
        return false
    }
    
}
