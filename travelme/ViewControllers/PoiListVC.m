//
//  PoiListVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiListVC.h"

@interface PoiListVC () <PoiListDelegate, LocatorDelegate>

@end

@implementation PoiListVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (PoiTVC *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PoiCell";
    
    PoiTVC *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[PoiTVC alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PoiNSO *poi;
    poi = [self.poiitems objectAtIndex:indexPath.row];
    /*
    cell.descr.text = l.descr;
    cell.vesselfullname.text = l.full_name_vessel;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MMM-yyyy HH:mm"];
    NSString *dateLastModified=[dateFormat stringFromDate:l.lastmodified];
    cell.lastmodifiedlabel.text = [NSString stringWithFormat:@"%@",dateLastModified];
    cell.ldportslabel.text = l.ld_ports;
    cell.tcelabel.text = [NSString stringWithFormat:@"TCE Per Day: %.2f", [l.tce doubleValue]];
    cell.l = l;
    cell.multipleSelectionBackgroundView.backgroundColor = [UIColor clearColor];
    */
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
    }
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
