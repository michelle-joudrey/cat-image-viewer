//
//  File.swift
//  cats
//
//  Created by Michelle J on 8/5/15.
//  Copyright © 2015 mjoudrey. All rights reserved.
//

import SDWebImage

/// The parameters for uniquely identifying cat images
struct CatImageParameters {
    var width : UInt16
    var height : UInt16
}

/// The mechanism for providing cat image -loading updates
protocol CatImageSourceDelegate {
    func finishedLoadingCatImageWithParameters(params: CatImageParameters, index: Int)
}

/// Loads cat images
class CatImageSource {
    var delegate : CatImageSourceDelegate?
    
    /// The container for storing loaded cat images parameters
    private var loadedCatImageParams : Array<CatImageParameters> = []
    
    /// The synchronization mechanism for accessing the loaded cat image parameters over multiple threads
    private var loadedCatImageParamsQueue = dispatch_queue_create("cats.CatImageSourceQueue", nil)
    
    /**
        Returns the number of cats loaded so far
    */
    func numberOfCatImagesLoaded() -> Int {
        var numLoaded = 0
        performBlockOnCatImageParameters { () -> Void in
            numLoaded = self.loadedCatImageParams.count
        }
        return numLoaded
    }
    
    /**
        Loads the cat image with the specified parameters
        If the image is not found in on-disk or in-memory cache it will be downloaded
        - Parameters:
            - params: The parameters of the cat image to load
    */
    func loadCatImageWithParameters(params: CatImageParameters) {
        SDWebImageManager.sharedManager().downloadImageWithURL(
            urlOfCatImageWithParameters(params),
            options: SDWebImageOptions(rawValue: 0),
            progress: nil,
            completed: { ( _, error: NSError!, _, _, imageURL: NSURL!) -> Void in
                if error != nil { // 0px by 0px image or some other issue
                    return
                }
                self.performBlockOnCatImageParameters({ () -> Void in
                    self.loadedCatImageParams.append(params)
                    let index = self.loadedCatImageParams.count - 1
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.finishedLoadingCatImageWithParameters(params, index: index)
                    })
                })
        })
    }
    
    func performBlockOnCatImageParameters(block: () -> Void) {
        dispatch_sync(self.loadedCatImageParamsQueue) {
            block()
        }
    }
    
    /**
        Cancels any pending cat image -loading requests
    */
    func cancelPendingCatImageLoadingRequests() {
        SDWebImageManager.sharedManager().cancelAll()
    }
    
    func cachedCatImageWithParameters(params: CatImageParameters) -> UIImage {
        let url = urlOfCatImageWithParameters(params)
        let cacheKey = SDWebImageManager.sharedManager().cacheKeyForURL(url)
        return SDImageCache.sharedImageCache().imageFromMemoryCacheForKey(cacheKey)
    }
    
    /**
        Returns the cat image parameters at the specified index
    */
    func catImageParametersAtIndex(index: Int) -> CatImageParameters {
        var params = CatImageParameters(width: 0, height: 0)
        performBlockOnCatImageParameters { () -> Void in
            params = self.loadedCatImageParams[index]
        }
        return params
    }
    
    /**
        Returns the URL for cat image associated with the specified parameters
    */
    func urlOfCatImageWithParameters(params: CatImageParameters) -> NSURL {
        return NSURL(string: "https://placekitten.com/g/\(params.width)/\(params.height)")!
    }
}
