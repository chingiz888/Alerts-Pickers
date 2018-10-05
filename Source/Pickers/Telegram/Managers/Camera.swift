//
//  Camera.swift
//  Alerts&Pickers
//
//  Created by Lex on 05.10.2018.
//  Copyright © 2018 Supreme Apps. All rights reserved.
//

import Foundation
import AVFoundation

public final class Camera {
    
    public enum CameraError: Error {
        case accessDenied
    }
    
    public enum StreamError: Error {
        case deviceUnsupported
    }
    
    public static func requestAccess(_ requestGranted: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            requestGranted(granted)
        }
    }
    
    public static var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    public enum CameraResult {
        case success(PreviewStream)
        case error(error: Error)
    }
    
    public enum StreamResult {
        case stream(PreviewStream)
        case error(error: Error)
    }
    
    public final class PreviewStream {
        
        public let device: AVCaptureDevice
        
        public let input: AVCaptureDeviceInput
        
        public let session: AVCaptureSession
        
        public init(device: AVCaptureDevice, input: AVCaptureDeviceInput, session: AVCaptureSession) {
            self.session = session
            self.input = input
            self.device = device
        }
        
        public func startIfNeeded() {
            
            guard !session.isRunning else {
                return
            }
            
            session.startRunning()
        }
        
        private static let queue = DispatchQueue(label: "CameraStream",
                                                 qos: .background,
                                                 attributes: [],
                                                 autoreleaseFrequency: .workItem,
                                                 target: nil)
        
        /// Completion handler performs on separate thread
        public static func create(_ completionHandler: @escaping (StreamResult)->()) {
            queue.async {
                let session = AVCaptureSession()
                guard let device = createDevice() else {
                    completionHandler(.error(error: StreamError.deviceUnsupported))
                    return
                }
                
                var input: AVCaptureDeviceInput!
                do {
                    let newInput = try AVCaptureDeviceInput.init(device: device)
                    session.addInput(newInput)
                    input = newInput
                }
                catch {
                    completionHandler(.error(error: error))
                    return
                }
                
                let stream = PreviewStream.init(device: device, input: input, session: session)
                completionHandler(.stream(stream))
            }
        }
        
        private static func createDevice() -> AVCaptureDevice? {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        }
        
    }
    
}
