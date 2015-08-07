//
//  ViewController.swift
//  cats
//
//  Created by Michelle J on 8/5/15.
//  Copyright © 2015 mjoudrey. All rights reserved.
//

import UIKit
import JTSImageViewController

class CatsViewController : UICollectionViewController {
    var catImageSource = CatImageSource()
    var numberOfCatImagesToShow = 0
    var numberOfQueuedCatImagesToLoad = 0
    
    /// Decrements numberOfQueuedCatImagesToLoad variable and
    /// checks to see if more images should be loaded from the image source
    func decrementNumberOfQueuedCatImagesToLoad() {
        --numberOfQueuedCatImagesToLoad
        if numberOfQueuedCatImagesToLoad == 0 && catImageSource.delegate != nil {
            if self.numberOfCatImagesToShow < 100 {
                loadSomeCatImages()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        catImageSource.delegate = self
        catImageSource.maxConcurrentCatImageDownloads = 3
        loadSomeCatImages()
    }
    
    /// Returns random multiple of 10 from [300, 1000]
    func randomImageDimension() -> UInt16 {
        return UInt16((arc4random_uniform(70) + 31) * 10)
    }
    
    /// Generates some cat image parameters, and loads the associated images
    func loadSomeCatImages() {
        let numToLoad = 10
        numberOfQueuedCatImagesToLoad += numToLoad
        var params = CatImageParameters(width: 0, height: 0)
        for _ in 1...numToLoad {
            params.width = randomImageDimension()
            params.height = randomImageDimension()
            catImageSource.loadCatImageWithParameters(params)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCatImagesToShow
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatCollectionViewCell", forIndexPath: indexPath) as! CatCollectionViewCell
        cell.catImageView?.image = catImageSource.cachedCatImageWithIndex(indexPath.row, getThumbnail: true)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageInfo = JTSImageInfo();
        let selectedCell = self.collectionView(self.collectionView!, cellForItemAtIndexPath: indexPath) as! CatCollectionViewCell
        imageInfo.image = catImageSource.cachedCatImageWithIndex(indexPath.row, getThumbnail: false)
        imageInfo.referenceRect = selectedCell.frame
        imageInfo.referenceView = collectionView
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image,
            backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
    func stopLoadingCatImages() {
        catImageSource.cancelPendingCatImageLoadingRequests()
        numberOfQueuedCatImagesToLoad = 0
    }
}

extension CatsViewController : CatImageSourceDelegate {
    func finishedLoadingCatImageWithParameters(params: CatImageParameters, index: Int) {
        ++numberOfCatImagesToShow
        collectionView?.insertItemsAtIndexPaths([
            NSIndexPath(forRow: index, inSection: 0) ])
        decrementNumberOfQueuedCatImagesToLoad()
    }
    
    func failedToLoadCatImageWithError(error: NSError) {
        decrementNumberOfQueuedCatImagesToLoad()
        let errorCodesToIgnore = [
            0,    // Occurs when a 0 pixel image is downloaded
            -1100 // Unknown. AFAIK this doesn't indicate that future images will fail to load
        ]
        if errorCodesToIgnore.contains(error.code) {
            return
        }
        stopLoadingCatImages()
        showErrorAlert(error)
    }
    
    func showErrorAlert(error: NSError) {
        let alertController = UIAlertController(
            title: "Error loading cat image",
            message: error.localizedDescription,
            preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default,
            handler: { (_) -> Void in
                self.dismissViewControllerAnimated(true, completion:nil)
        }));
        // The topmost view controller could be the JTSImageViewController;
        // If it is, the UIAlertController must be presented on it
        let activeViewController = self.presentedViewController != nil ? self.presentedViewController! : self
        activeViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
