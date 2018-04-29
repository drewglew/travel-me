//
//  PoiListVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiListVC.h"

@interface PoiListVC () <PoiListDelegate, LocatorDelegate, PoiDataEntryDelegate>

@end

@implementation PoiListVC

@synthesize delegate;

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;
    // Do any additional setup after loading the view.
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadPoiData];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void) LoadPoiData {
    self.poiitems = [self.db GetPoiContent :nil];
    [self.tableView reloadData];
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poiitems.count;
}

/*
 created date:      27/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (PoiListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PoiCell";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];

    PoiListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.poi = [self.poiitems objectAtIndex:indexPath.row];
    cell.Name.text = cell.poi.name;
    cell.AdministrativeArea.text = cell.poi.administrativearea;
    
    if (cell.poi.Images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        PoiImageNSO *FirstImageItem = [cell.poi.Images firstObject];
    
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",FirstImageItem.ImageFileReference]];

        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    
        cell.PoiKeyImage.image = [UIImage imageWithData:pngData];
    }
    return cell;
}


/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowLocator"]){
        LocatorVC *controller = (LocatorVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
    } else if ([segue.identifier isEqualToString:@"ShowPoi"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        if ([sender isKindOfClass: [PoiListCell class]]) {
            PoiListCell *cell = (PoiListCell *)sender;
            controller.PointOfInterest = cell.poi;
        }
        controller.newitem = false;
    }
    
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
