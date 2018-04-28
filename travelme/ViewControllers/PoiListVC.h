//
//  PoiListVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiNSO.h"
#import "PoiListCell.h"
#import "Dal.h"
#import "LocatorVC.h"
#import "PoiDataEntryVC.h"

@protocol PoiListDelegate <NSObject>
@end

@interface PoiListVC : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *poiitems;
@property (strong, nonatomic) Dal *db;
@property (nonatomic, weak) id <PoiListDelegate> delegate;

@end
