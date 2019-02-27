//
//  ToolBoxNSO.m
//  travelme
//
//  Created by andrew glew on 02/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ToolBoxNSO.h"

@implementation ToolBoxNSO

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (UIImage*)resizeImage:(UIImage*)image toFitInSize:(CGSize)toSize
{
    UIImage *result = image;
    CGSize sourceSize = image.size;
    CGSize targetSize = toSize;
    
    BOOL needsRedraw = NO;
    
    // Check if width of source image is greater than width of target image
    // Calculate the percentage of change in width required and update it in toSize accordingly.
    
    if (sourceSize.width > toSize.width) {
        
        CGFloat ratioChange = (sourceSize.width - toSize.width) * 100 / sourceSize.width;
        
        toSize.height = sourceSize.height - (sourceSize.height * ratioChange / 100);
        
        needsRedraw = YES;
    }
    
    // Now we need to make sure that if we chnage the height of image in same proportion
    // Calculate the percentage of change in width required and update it in target size variable.
    // Also we need to again change the height of the target image in the same proportion which we
    /// have calculated for the change.
    
    if (toSize.height < targetSize.height) {
        
        CGFloat ratioChange = (targetSize.height - toSize.height) * 100 / targetSize.height;
        
        toSize.height = targetSize.height;
        toSize.width = toSize.width + (toSize.width * ratioChange / 100);
        
        needsRedraw = YES;
    }
    
    // To redraw the image
    
    if (needsRedraw) {
        UIGraphicsBeginImageContext(toSize);
        [image drawInRect:CGRectMake(0.0, 0.0, toSize.width, toSize.height)];
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Return the result
    
    return result;
}


/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:           Present the pretty date formats of start and end.  If activity is checked out give the user detail of how long instead of duplicated date.
 */
+(NSString*)PrettyDateDifference :(NSDate*)Start :(NSDate*)End :(NSString*) PostFixText {
    
    NSString *PrettyDate = @"";
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:Start toDate:End options:0];
    
    NSInteger days = components.day;
    NSInteger hours = components.hour;
    NSInteger minutes = components.minute;
    
    // format text for plural/singular in EN only.
    NSString *DaysText = @"days";
    NSString *HoursText = @"hours";
    NSString *MinutesText = @"minutes";
    if (days==1) {
        DaysText = @"day";
    }
    if (hours==1) {
        HoursText = @"hour";
    }
    if (minutes==1) {
        MinutesText = @"minute";
    }
    
    if (days==0) {
        if (hours==0) {
            if (minutes==0) {
                // do nothing
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)minutes, MinutesText, PostFixText];
            }
            
        } else {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)hours, HoursText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)hours, HoursText, (long)minutes, MinutesText, PostFixText];
            }
        }
    } else {
        if (hours==0) {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)days, DaysText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)days, DaysText, (long)minutes, MinutesText, PostFixText];
            }
            
        } else {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)days, DaysText, (long)hours, HoursText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@, %ld %@ and %ld %@%@", (long)days, DaysText, (long)hours, HoursText, (long)minutes, MinutesText, PostFixText ];
            }
        }
    }
    return PrettyDate;
}

/*
 created date:      22/10/2018
 last modified:     21/02/2019
 remarks:
 */
+ (NSString*)FormatPrettyDate :(NSDate*)Dt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@ %@",[dateformatter stringFromDate:Dt], [timeformatter stringFromDate:Dt]];
}


@end
