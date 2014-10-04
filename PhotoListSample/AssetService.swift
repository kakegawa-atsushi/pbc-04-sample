//
//  AssetService.swift
//  PhotoListSample
//
//  Created by kakegawa.atsushi on 2014/10/04.
//  Copyright (c) 2014年 Classmethod Inc. All rights reserved.
//

import Foundation
import Photos

class AssetService {
    
    func fetchImageAssets() -> [PHAsset] {
        var assets = [PHAsset]()
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        fetchResult?.enumerateObjectsUsingBlock { result, index, stop in
            if let asset = result? as? PHAsset {
                assets.append(asset)
            }
        }
        
        return assets
    }
    
    class func checkAndRequestAuthorizationWithCompletion(completion: PHAuthorizationStatus -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Authorized:
            completion(status)
        default:
            PHPhotoLibrary.requestAuthorization { status in
                completion(status)
            }
        }
    }
    
}

extension PHAsset {
    
    func fetchImageWithSize(targetSize: CGSize, completion: UIImage? -> Void) {
        let imageManager = PHImageManager.defaultManager()
        
        imageManager.requestImageForAsset(self,
            targetSize: targetSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { image, info in
                completion(image)
            }
        )
    }
    
}
