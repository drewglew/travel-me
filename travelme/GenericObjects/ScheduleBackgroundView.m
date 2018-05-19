//
//  ScheduleBackgroundView.m
//  travelme
//
//  Created by andrew glew on 17/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleBackgroundView.h"

@implementation ScheduleBackgroundView


-(void)addColumns:(int)amount {
    
    NSLog(@"addcolumns - amount:%d",amount);
    
    columns = [[NSMutableArray alloc] init];
    for (int i = 0; i < amount; i++)
    {
        float position = (20 * i ) + 10;
        [columns addObject:[NSNumber numberWithFloat:position]];
    }
   
}

-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    NSLog(@"drawRect - count of columns:%lu",(unsigned long)columns.count);
    
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(ctx, 3.0);
    
    for (int i = 0; i < [columns count]; i++) {
        CGFloat f = [((NSNumber*) [columns objectAtIndex:i]) floatValue];
        CGContextMoveToPoint(ctx, f, 0);
        CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
    }
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}


@end
