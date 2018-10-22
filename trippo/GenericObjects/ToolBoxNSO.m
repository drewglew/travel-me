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




@end
