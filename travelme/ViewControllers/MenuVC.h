//
//  MenuVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PoiSearchVC.h"
#import "ProjectListVC.h"
#import "ProjectDataEntryVC.h"
#import "ActivityListVC.h"
#import "PoiNSO.h"
#import "PoiDataEntryVC.h"

@interface MenuVC : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, ProjectDataEntryDelegate, ActivityListDelegate, PoiDataEntryDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ButtonProject;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPoi;
@property (weak, nonatomic) IBOutlet UIButton *ButtonInfo;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPreviewPanel;
@property (strong, nonatomic) NSMutableArray *alltripitems;
@property (strong, nonatomic) NSMutableArray *selectedtripitems;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSettings;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewFeaturedPoi;


@property (assign) bool SetReload;
@property (strong, nonatomic) PoiNSO *FeaturedPoi;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonShowPoiListing;

@end
