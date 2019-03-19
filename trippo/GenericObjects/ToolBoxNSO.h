//
//  ToolBoxNSO.h
//  travelme
//
//  Created by andrew glew on 02/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolBoxNSO : NSObject
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (UIImage*)resizeImage:(UIImage*)image toFitInSize:(CGSize)toSize;
+ (NSString*)PrettyDateDifference :(NSDate*)Start :(NSDate*)End :(NSString*) PostFixText;
+ (NSString*)FormatPrettyDate :(NSDate*)Dt;
+ (UIImage *)convertImageToGrayScale:(UIImage *)image ;
@end
