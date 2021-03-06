// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping

#import "UIImage+Alpha.h"
#import "UIImage+RoundedCorner.h"

@interface UIImage (Resize)

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImagetoFit:(CGSize)size;
@end
