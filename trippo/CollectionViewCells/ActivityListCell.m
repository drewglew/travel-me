//
//  ActivityListCell.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListCell.h"

@implementation ActivityListCell
/*
-(UIColor *)averageColorOfImage:(UIImage*)image{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}
*/
- (void)layoutSubviews {
    [super layoutSubviews];
    self.ButtonDelete.layer.cornerRadius = 15;
    self.ButtonDelete.clipsToBounds = YES;
    self.ButtonDelete.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    

    self.ViewPoiType.layer.cornerRadius = 15;
    self.ViewPoiType.clipsToBounds = YES;
    
    //self.LabelActivityLegend.layer.cornerRadius = 15;
    //self.LabelActivityLegend.layer.masksToBounds = YES;
   
}


@end