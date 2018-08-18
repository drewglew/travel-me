//
//  ProjectListCell.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectListCell.h"

@implementation ProjectListCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.RotatingView setTransform:CGAffineTransformMakeRotation(M_PI_2)];

    //self.editButton.layer.cornerRadius = 15;
    //self.editButton.clipsToBounds = YES;
    //self.editButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    
    self.deleteButton.layer.cornerRadius = 15;
    self.deleteButton.clipsToBounds = YES;
    self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
}


- (IBAction)BackButton:(id)sender {
}
@end
