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
    
    func fetchImageAssetsWithCompletion(completion: [PHAsset] -> Void) {
        dispatch_async(dispatch_get_global_queue(NSQualityOfService.UserInitiated.toRaw(), 0)) {
            var assets = [PHAsset]()
            
            let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            fetchResult?.enumerateObjectsUsingBlock { result, index, stop in
                if let asset = result as? PHAsset {
                    assets.append(asset)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(assets)
            }
        }
    }
    
    class func checkAndRequestAuthorizationWithCompletion(completion: PHAuthorizationStatus -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Authorized:
            completion(status)
        default:
            PHPhotoLibrary.requestAuthorization(completion)
        }
    }
    
    func fetchImageWithSize(asset: PHAsset, targetSize: CGSize, completion: UIImage? -> Void) {
        let imageManager = PHImageManager.defaultManager()
        
        imageManager.requestImageForAsset(asset,
            targetSize: targetSize,
            contentMode: PHImageContentMode.AspectFill,
            options: nil,
            resultHandler: { image, info in
                completion(image)
            }
        )
    }
    
}
