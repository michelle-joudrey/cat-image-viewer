//
//  UIImage+UIImage_Resize.h
//  
//
//  Created by Michelle J on 8/6/15.
//
//

// source: https://github.com/mbcharbonneau/UIImage-Categories/blob/master/UIImage%2BResize.h

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Resize)
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
@end
