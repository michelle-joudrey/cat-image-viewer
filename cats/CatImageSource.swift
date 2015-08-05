//
//  File.swift
//  cats
//
//  Created by Michelle J on 8/5/15.
//  Copyright © 2015 mjoudrey. All rights reserved.
//

import SDWebImage

protocol CatImageSourceDelegate {
    func refreshCatImages()
}

// TODO: Display thumbnail of kittens

class CatImageSource {
    var delegate : CatImageSourceDelegate?
    var loadedCats : Array<(Int, Int)> = []
    let numCatsToLoad = 250
    
    var queue = dispatch_queue_create("cats.CatImageSourceQueue", nil)
    
    func urlForCatImageWithWidth(width: Int, height: Int) -> NSURL {
        return NSURL(string: "https://placekitten.com/g/\(width)/\(height)")!
    }
    func numberOfCatsLoaded() -> Int {
        var numLoaded = 0
        dispatch_sync(self.queue) {
            numLoaded = self.loadedCats.count
        }
        return numLoaded
    }
    func urlForCatImageWithIndex(index: Int) -> NSURL {
        var catAtIndex = (0, 0)
        dispatch_sync(self.queue) {
            catAtIndex = self.loadedCats[index]
        }
        return urlForCatImageWithWidth(catAtIndex.0, height: catAtIndex.1)
    }
    func getCatImageWithWidth(width: Int, height: Int) {
        SDWebImageManager.sharedManager().downloadImageWithURL(
            urlForCatImageWithWidth(width, height: height),
            options: SDWebImageOptions(rawValue: 0),
            progress: nil,
            completed: { ( image: UIImage!, error: NSError!, cacheType: SDImageCacheType, finished: Bool, imageURL: NSURL!) -> Void in
                if error != nil { // 0px by 0px image or some other issue
                    return
                }
                // prevent race conditions from simultaneous read/write access over multiple threads
                dispatch_sync(self.queue) {
                    self.loadedCats.append((width, height))
                    // TODO: Do this every so many images instead of every one
                    self.delegate?.refreshCatImages()
                    if self.loadedCats.count == self.numCatsToLoad {
                        self.finishedLoadingCats()
                    }
                }
        })
    }
    func startLoadingCatImages() {
        for width in 1...100 {
            for height in 1...100 {
                getCatImageWithWidth(width * 5, height: height * 5)
            }
        }
    }
    func finishedLoadingCats() {
        NSLog("Finished!");
        SDWebImageManager.sharedManager().cancelAll()
    }
}