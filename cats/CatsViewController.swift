//
//  ViewController.swift
//  cats
//
//  Created by Michelle J on 8/5/15.
//  Copyright © 2015 mjoudrey. All rights reserved.
//

import UIKit
import SDWebImage
import JTSImageViewController

class CatsViewController : UICollectionViewController, CatImageSourceDelegate {
    var catImageSource = CatImageSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        catImageSource.delegate = self
        catImageSource.startLoadingCatImages()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catImageSource.numberOfCatsLoaded()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatCollectionViewCell", forIndexPath: indexPath) as! CatCollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        cell.catImageView?.sd_setImageWithURL(catImageSource.urlForCatImageWithIndex(indexPath.row))
        return cell
    }
    
    func refreshCatImages() {
        self.collectionView?.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageInfo = JTSImageInfo();
        let selectedCell = self.collectionView(self.collectionView!, cellForItemAtIndexPath: indexPath) as! CatCollectionViewCell
        imageInfo.image = selectedCell.catImageView?.image
        imageInfo.referenceRect = selectedCell.frame
        imageInfo.referenceView = collectionView
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image,
            backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }

}

