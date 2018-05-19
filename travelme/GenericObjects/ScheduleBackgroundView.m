//
//  ScheduleBackgroundView.m
//  travelme
//
//  Created by andrew glew on 17/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleBackgroundView.h"

@implementation ScheduleBackgroundView

/*
 created date:      19/05/2018
 last modified:     19/05/2018
 remarks:
 */
-(void)addColumns:(int)amount :(int)linestyle {
    LastLineStyle = linestyle;
    columns = [[NSMutableArray alloc] init];
    for (int i = 0; i < amount; i++)
    {
        float position = (20 * i ) + 20;
        [columns addObject:[NSNumber numberWithFloat:position]];
    }
}
/*
 created date:      19/05/2018
 last modified:     19/05/2018
 remarks:
 */
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:246.0f/255.0f green:71.0f/255.0f blue:64.0f/255.0f alpha:1.0] CGColor]);

    CGContextSetLineWidth(ctx, 6.0);
    
    for (int i = 0; i < [columns count]; i++) {
        CGFloat f = [((NSNumber*) [columns objectAtIndex:i]) floatValue];
        //last line
        if (i == columns.count - 1) {
            CGFloat midHeight = self.bounds.size.height / 2;
            if (LastLineStyle==0) {
                CGContextMoveToPoint(ctx, f, midHeight);
                CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
            } else if (LastLineStyle==2) {
                CGContextMoveToPoint(ctx, f, 0);
                CGContextAddLineToPoint(ctx, f, midHeight);
            } else if (LastLineStyle==3) {
                // no line
            } else {
                CGContextMoveToPoint(ctx, f, 0);
                CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
            }
        } else {
            CGContextMoveToPoint(ctx, f, 0);
            CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
        }
    }
    CGContextStrokePath(ctx);
    [super drawRect:rect];
}


@end
