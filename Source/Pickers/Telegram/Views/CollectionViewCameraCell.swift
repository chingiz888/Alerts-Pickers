import Foundation
import UIKit
import AVFoundation

public class CollectionViewCameraCell: CollectionViewCustomContentCell<CameraView> {
    
    public override func setup() {
        super.setup()
        
        selectionElement.isHidden = true
    }
    
}

public final class CameraView: UIView {
    
    public var representedStream: Camera.PreviewStream? = nil {
        didSet {
            guard representedStream != oldValue else {
                return
            }
            self.setup()
        }
    }
    
    private var videoLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            guard oldValue !== videoLayer else {
                return
            }
            
            oldValue?.removeFromSuperlayer()
            
            if let newLayer = videoLayer {
                self.layer.addSublayer(newLayer)
            }
        }
    }
    
    private func setup() {
        self.videoLayer = nil
        
        if let stream = self.representedStream {
            stream.queue.async {
                let videoLayer = AVCaptureVideoPreviewLayer.init(session: stream.session)
                videoLayer.videoGravity = .resizeAspectFill
                DispatchQueue.main.async {
                    self.videoLayer = videoLayer
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        videoLayer?.frame = self.bounds
    }
    
    public func reset() {
        self.representedStream = nil
    }
    
}
