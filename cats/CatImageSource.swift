//
//  File.swift
//  cats
//
//  Created by Michelle J on 8/5/15.
//  Copyright © 2015 mjoudrey. All rights reserved.
//

import SDWebImage
import ImageIO

/// The parameters for uniquely identifying cat images
struct CatImageParameters {
    var width : UInt16
    var height : UInt16
}

/// The mechanism for providing cat image -loading updates
protocol CatImageSourceDelegate {
    func finishedLoadingCatImageWithParameters(params: CatImageParameters, index: Int)
    func failedToLoadCatImageWithError(error : NSError)
}

/// Loads cat images
class CatImageSource {
    /// The object to provide cat image -loading updates to
    var delegate : CatImageSourceDelegate?
    
    /// The container for storing loaded cat images parameters
    private var loadedCatImageParams : Array<CatImageParameters> = []
    
    /// Returns the number of cats loaded so far
    func numberOfCatImagesLoaded() -> Int {
        return self.loadedCatImageParams.count
    }
    
    /// The maximum number cat images to download simultaneously
    var maxConcurrentCatImageDownloads = 0 {
        didSet {
            SDWebImageDownloader.sharedDownloader().maxConcurrentDownloads = maxConcurrentCatImageDownloads
        }
    }
    
    /**
        Queues the loading of the cat image with the specified parameters.
        If the image is not found in on-disk or in-memory cache it will be downloaded.
        If the fails to load, the delegate method failedToLoadCatImageWithError will be called.
        if the image finishes loading successfully, the delegate method 
           finishedLoadingCatImageWithParameters will be called.
        - Parameters:
            - params: The parameters of the cat image to load
    */
    func loadCatImageWithParameters(params: CatImageParameters) {
        let imageManager = SDWebImageManager.sharedManager()
        imageManager.downloadImageWithURL(
            urlOfCatImageWithParameters(params),
            options: SDWebImageOptions.LowPriority, // Give performance priority to UI
            progress: nil,
            completed: { ( image : UIImage?, error: NSError!, cacheType: SDImageCacheType, _, imageURL: NSURL!) -> Void in
                if error != nil { // 0px by 0px image or some other issue
                    self.delegate?.failedToLoadCatImageWithError(error)
                    return
                }
                if cacheType == SDImageCacheType.None {
                    self.createThumbnailOfCatImage(image!, url: imageURL)
                }
                self.loadedCatImageParams.append(params)
                let index = self.loadedCatImageParams.count - 1
                self.delegate?.finishedLoadingCatImageWithParameters(params, index: index)
        })
    }
    
    let thumbnailCacheKeySuffix = "_t"

    func createThumbnailOfCatImage(image: UIImage, url: NSURL) {
        let thumbnail =  image.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFill,
            bounds: CGSize(width: 50, height: 50), interpolationQuality: CGInterpolationQuality.Medium)
        let cacheKey = SDWebImageManager.sharedManager().cacheKeyForURL(url) + thumbnailCacheKeySuffix
        SDImageCache.sharedImageCache().storeImage(thumbnail, forKey: cacheKey)
    }
    
    /// Cancels any pending cat image -loading requests
    func cancelPendingCatImageLoadingRequests() {
        SDWebImageManager.sharedManager().cancelAll()
    }
    
    /// Returns the cached cat image with the specified parameters, optionally the thumbnail
    func cachedCatImageWithParameters(params: CatImageParameters, getThumbnail: Bool) -> UIImage {
        let url = urlOfCatImageWithParameters(params)
        var cacheKey = SDWebImageManager.sharedManager().cacheKeyForURL(url)
        if getThumbnail {
            cacheKey = cacheKey + thumbnailCacheKeySuffix
        }
        // note: imageFromDiskCacheForKey will first attempt to read from the
        // in-memory cache before reading from the disk
        return SDImageCache.sharedImageCache().imageFromDiskCacheForKey(cacheKey)
    }
    
    // Convienence function
    func cachedCatImageWithIndex(index: Int, getThumbnail: Bool) -> UIImage {
        let catImageParams = catImageParametersAtIndex(index)
        return cachedCatImageWithParameters(catImageParams, getThumbnail: false)
    }
    
    /// Returns the cat image parameters at the specified index
    func catImageParametersAtIndex(index: Int) -> CatImageParameters {
        return self.loadedCatImageParams[index]
    }
    
    /// Returns the URL for cat image associated with the specified parameters
    func urlOfCatImageWithParameters(params: CatImageParameters) -> NSURL {
        return NSURL(string: "https://placekitten.com/g/\(params.width)/\(params.height)")!
    }
}
