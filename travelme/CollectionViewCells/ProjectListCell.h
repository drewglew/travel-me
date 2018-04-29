//
//  ProjectListCell.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectNSO.h"

@interface ProjectListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelProjectName;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewProject;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (assign) bool isNewAccessor;
@property (strong, nonatomic) ProjectNSO *project;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisualEffectsViewBlur;
@end
