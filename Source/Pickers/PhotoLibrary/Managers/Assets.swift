import Foundation
import UIKit
import Photos

public struct Assets {
    
    /// Requests access to the user's contacts
    ///
    /// - Parameter requestGranted: Result as Bool
    public static func requestAccess(_ requestGranted: @escaping (PHAuthorizationStatus) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            requestGranted(status)
        }
    }
    
    /// Result Enum
    ///
    /// - Success: Returns Array of PHAsset
    /// - Error: Returns error
    public enum FetchResults {
        case success(response: [PHAsset])
        case error(error: Error)
    }
    
    public enum OriginalFetchResults {
        case success(result: PHFetchResult<PHAsset>)
        case error(error: Error)
    }
    
    
    public static func fetchOriginal(_ completion: @escaping (OriginalFetchResults)-> Void ) {
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            let error: NSError = NSError(domain: "PhotoLibrary Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "No PhotoLibrary Access"])
            completion(OriginalFetchResults.error(error: error))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            
            DispatchQueue.main.async {
                completion(.success(result: fetchResult))
            }
        }
        
    }
    
    public static func fetch(_ completion: @escaping (FetchResults) -> Void) {
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            let error: NSError = NSError(domain: "PhotoLibrary Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "No PhotoLibrary Access"])
            completion(FetchResults.error(error: error))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            
            // MARK: Is it ok we don't call completion if there is no photo in library?
            if fetchResult.count > 0 {
                
                let assets = fetchResult.dlg_assets
                
                DispatchQueue.main.async {
                    completion(FetchResults.success(response: assets))
                }
            }
        }
    }
    
    /// Result Enum
    ///
    /// - Success: Returns UIImage
    /// - Error: Returns error
    public enum ResolveResult {
        case success(response: UIImage?)
        case error(error: Error)
    }
    
    public static func resolve(asset: PHAsset, size: CGSize = PHImageManagerMaximumSize, completion: @escaping (_ image: UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageManager = PHImageManager.default()
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            requestOptions.isNetworkAccessAllowed = true
            
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    public static func resolveVideo(asset: PHAsset, size: CGSize = PHImageManagerMaximumSize, completion: @escaping (_ image: URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let imageManager = PHImageManager.default()
            
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            
            imageManager.requestAVAsset(forVideo: asset, options: options) { (asset, audioMix, info) in
                DispatchQueue.main.async {
                    if let urlAsset = asset as? AVURLAsset {
                        completion(urlAsset.url)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    /// Result Enum
    ///
    /// - Success: Returns Array of UIImage
    /// - Error: Returns error
    public enum ResolveResults {
        case success(response: [UIImage])
        case error(error: Error)
    }
    
    public static func resolve(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ images: [UIImage]) -> Void) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        
        DispatchQueue.main.async {
            completion(images)
        }
        
        return images
    }
}
