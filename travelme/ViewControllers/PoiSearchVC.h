//
//  ActivityDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ActivityNSO.h"
#import "PoiNSO.h"
#import "PoiListCell.h"
#import "ActivityDataEntryVC.h"
#import "ProjectNSO.h"
#import "LocatorVC.h"
#import "NearbyListingVC.h"
#import "TypeNSO.h"
#import "TypeCell.h"

@protocol PoiSearchDelegate <NSObject>

@end

@interface PoiSearchVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, ActivityDelegate, LocatorDelegate, PoiDataEntryDelegate, NearbyListingDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBarPoi;
@property (weak, nonatomic) IBOutlet UITableView *TableViewSearchPoiItems;
@property (strong, nonatomic) NSMutableArray *poiitems;
@property (strong, nonatomic) PoiNSO *PointOfInterest;
@property (strong, nonatomic) NSMutableArray *poifiltereditems;
@property (strong, nonatomic) NSMutableArray *countries;
@property (assign) bool newitem;
@property (assign) bool transformed;
@property (assign) bool isSearching;
@property (nonatomic, weak) id <PoiSearchDelegate> delegate;
@property (strong, nonatomic) ActivityNSO *Activity;
@property (strong, nonatomic) ProjectNSO *Project;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentPoiFilterList;

@property (weak, nonatomic) IBOutlet UILabel *LabelCounter;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonNew;
@property (weak, nonatomic) IBOutlet UIButton *ButtonFilter;
@property (weak, nonatomic) IBOutlet UIButton *ButtonResetFilter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentCountries;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FilterOptionHeightConstraint;

@property (strong, nonatomic) NSArray *TypeItems;
@property (strong, nonatomic) NSMutableArray *PoiTypes;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewTypes;

@end
