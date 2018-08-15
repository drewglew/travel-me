//
//  ProjectListVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ProjectListCell.h"
#import "ActivityListVC.h"
#import "ProjectDataEntryVC.h"

@protocol ProjectListDelegate <NSObject>
@end

@interface ProjectListVC : UIViewController <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ActivityListDelegate, ProjectDataEntryDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewProjects;
@property (strong, nonatomic) NSMutableArray *projectitems;
@property (strong, nonatomic) NSMutableArray *filteredprojectitems;
@property (assign) bool editmode;
@property (nonatomic, weak) id <ProjectListDelegate> delegate;
@property (strong, nonatomic) ProjectNSO *Trip;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentFilterProjects;

@end
