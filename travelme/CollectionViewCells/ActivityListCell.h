//
//  ActivityListCell.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
@interface ActivityListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewActivity;
@property (strong, nonatomic) ActivityNSO *activity;
@property (weak, nonatomic) IBOutlet UILabel *LabelName;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisualViewBlur;



@end
