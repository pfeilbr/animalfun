//
//  UIImageResizing.m
//  AnimalFun
//
//  Created by Brian Pfeil on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "UIImageResizing.h"


@implementation UIImage (Resizing)

- (UIImage*)scaleToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

@end
