//
//  TextFieldDatePicker.m
//  trippo
//
//  Created by andrew glew on 22/10/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "TextFieldDatePicker.h"

@implementation TextFieldDatePicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

- (BOOL)becomeFirstResponder {
    BOOL outcome = [super becomeFirstResponder];
    if (outcome) {
        self.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0];
        self.textColor = [UIColor blackColor];
    }
    return outcome;
}

- (BOOL)resignFirstResponder {
    BOOL outcome = [super resignFirstResponder];
    if (outcome) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor whiteColor];
    }
    return outcome;
}


@end
