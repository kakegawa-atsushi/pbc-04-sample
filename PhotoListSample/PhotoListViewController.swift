//
//  ViewController.swift
//  PhotoListSample
//
//  Created by kakegawa.atsushi on 2014/10/04.
//  Copyright (c) 2014年 Classmethod Inc. All rights reserved.
//

import UIKit
import Photos

class PhotoListViewController: UICollectionViewController {
    
    private struct CellIdentifier {
        static let ImageCell = "ImageCellIdentifier"
    }
    
    private var assets: [PHAsset]?
    private var cellSize: CGSize!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = self.view.bounds.width
        self.cellSize = CGSize(width: viewWidth, height: viewWidth)
        self.configureFlowLayout(self.cellSize)
        
        self.checkAndRequestAuthorizationWithCompletion { status in
            if status == .Authorized {
                self.loadAssets()
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView?
            .dequeueReusableCellWithReuseIdentifier(CellIdentifier.ImageCell, forIndexPath: indexPath) as CollectionViewImageCell
        
        if let asset = self.assets?[indexPath.item] {
            self.fetchImageWithSize(asset, targetSize: self.cellSize) { image in
                cell.imageView.image = image
            }
        }
        
        return cell
    }

    // MARK: Private

    private func configureFlowLayout(cellSize: CGSize) {
        let collectionViewFlowLayout = self.collectionViewLayout as UICollectionViewFlowLayout
        
        collectionViewFlowLayout.itemSize = cellSize
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionViewFlowLayout.minimumLineSpacing = 1.0
    }

    private func loadAssets() {
        self.fetchImageAssetsWithCompletion { assets in
            self.assets = assets
            self.collectionView?.reloadData()
        }
    }
    
    private func fetchImageAssetsWithCompletion(completion: [PHAsset] -> Void) {
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
    
    private func checkAndRequestAuthorizationWithCompletion(completion: PHAuthorizationStatus -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Authorized:
            completion(status)
        default:
            PHPhotoLibrary.requestAuthorization(completion)
        }
    }
    
    private func fetchImageWithSize(asset: PHAsset, targetSize: CGSize, completion: UIImage? -> Void) {
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

