//
//  OptionButton.m
//  trippo
//
//  Created by andrew glew on 22/10/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "OptionButton.h"

@implementation OptionButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = self.bounds.size.width/2;
        self.clipsToBounds = YES;
        self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
    }
    return self;
}

@end
