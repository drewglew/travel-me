//
//  ActivityListVC.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectNSO.h"
#import "Dal.h"

@protocol ActivityDelegate <NSObject>
@end

@interface ActivityListVC : UIViewController

@property (strong, nonatomic) Dal *db;
@property (strong, nonatomic) ProjectNSO *Project;
@property (nonatomic, weak) id <ActivityDelegate> delegate;
@end
