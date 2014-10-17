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
    
    private var assets: [PHAsset]?
    
    init() {
    }
    
    var assetsCount: Int {
        return self.assets?.count ?? 0
    }
    
    func assetAtIndex(index: Int) -> PHAsset? {
        switch self.assets {
        case .Some(let assets) where index >= 0 && index < assets.count:
            return assets[index]
        default:
            return nil
        }
    }
    
    func fetchImageAssetsWithCompletion(completion: Bool -> Void) {
        dispatch_async(dispatch_get_global_queue(NSQualityOfService.UserInitiated.toRaw(), 0)) {
            var assets = [PHAsset]()
            
            let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            fetchResult?.enumerateObjectsUsingBlock { result, index, stop in
                if let asset = result as? PHAsset {
                    assets.append(asset)
                }
            }
            
            self.assets = assets
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(true)
            }
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
    
    class func checkAndRequestAuthorizationWithCompletion(completion: PHAuthorizationStatus -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Authorized:
            completion(status)
        default:
            PHPhotoLibrary.requestAuthorization(completion)
        }
    }
    
}
