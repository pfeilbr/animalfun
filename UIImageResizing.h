//
//  UIImageResizing.h
//  AnimalFun
//
//  Created by Brian Pfeil on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
@end
