import Foundation
import UIKit
import AVFoundation

public typealias CollectionViewCameraCell = CollectionViewCustomContentCell<CameraView>

public final class CameraView: UIView {
    
    public final class RepresentedStream: Equatable {
        
        fileprivate let cameraStream: Camera.PreviewStream
        
        fileprivate let layer: AVCaptureVideoPreviewLayer
        
        fileprivate init(layer: AVCaptureVideoPreviewLayer, stream: Camera.PreviewStream) {
            self.layer = layer
            self.cameraStream = stream
        }
        
        public static func == (lhs: RepresentedStream, rhs: RepresentedStream) -> Bool {
            return lhs.layer.session == rhs.layer.session
        }
        
        public class func create(cameraStream: Camera.PreviewStream, completionHandler: @escaping (RepresentedStream)->()) {
            DispatchQueue.global(qos: .background).async {
                
                let newVideoLayer = AVCaptureVideoPreviewLayer.init(session: cameraStream.session)
                cameraStream.startIfNeeded()
                let representedStream = RepresentedStream.init(layer: newVideoLayer, stream: cameraStream)
                
                DispatchQueue.main.async {
                    completionHandler(representedStream)
                }
            }
        }
        
    }
    
    public var representedStream: RepresentedStream? = nil {
        didSet {
            guard representedStream != oldValue else {
                return
            }
            
            if let oldValue = oldValue {
                oldValue.layer.removeFromSuperlayer()
            }
            
            if let stream = representedStream {
                self.layer.addSublayer(stream.layer)
            }
        }
    }
    
    private var videoLayer: AVCaptureVideoPreviewLayer? {
        return self.representedStream?.layer
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer = videoLayer {
            layer.frame = self.bounds
        }
    }
    
    public func reset() {
        self.representedStream = nil
    }
    
    public func isRepresentingCameraStream(_ stream: Camera.PreviewStream) -> Bool {
        if let layer = videoLayer, let session = layer.session {
            return session === stream.session
        }
        return false
    }
    
}
