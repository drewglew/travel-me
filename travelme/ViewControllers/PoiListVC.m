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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self LoadPoiData];
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) LoadPoiData {
    self.poiitems = [self.db GetPoiContent :nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poiitems.count;
}

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
    
    PoiImageNSO *FirstImageItem = [cell.poi.Images firstObject];
    
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",FirstImageItem.ImageFileReference]];

    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    cell.PoiKeyImage.image = [UIImage imageWithData:pngData];
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
