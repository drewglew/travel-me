//
//  ActivityDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiSearchVC.h"

@interface PoiSearchVC ()

@end

@implementation PoiSearchVC

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBarPoi.delegate = self;
    self.TableViewSearchPoiItems.delegate = self;
    self.TableViewSearchPoiItems.rowHeight = 100;
    self.poifiltereditems = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
}
/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadPoiData];
}

/*
 created date:      03/05/2018
 last modified:     03/05/2018
 remarks:
 */
-(void)RefreshPoiFilteredData {
    //[self.SearchBarPoi resignFirstResponder];
    [self.poifiltereditems removeAllObjects];
    [self.poifiltereditems addObjectsFromArray: self.poiitems];
    [self.TableViewSearchPoiItems reloadData];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
-(void) LoadPoiData {
    self.poiitems = [self.db GetPoiContent :nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (PoiNSO *poi in self.poiitems) {
        if (poi.Images.count > 0) {
            PoiImageNSO *FirstImageItem = [poi.Images firstObject];
            NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",FirstImageItem.ImageFileReference]];
            NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
            FirstImageItem.Image = [UIImage imageWithData:pngData];
        }
    }
    [self.poifiltereditems removeAllObjects];
    [self.poifiltereditems addObjectsFromArray: self.poiitems];
    [self.TableViewSearchPoiItems reloadData];
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poifiltereditems.count;
}

/*
 created date:      30/04/2018
 last modified:     03/04/2018
 remarks:
 */
- (PoiListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchPoiCellId";
    PoiListCell *cell = [self.TableViewSearchPoiItems dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.poi = [self.poifiltereditems objectAtIndex:indexPath.row];
    cell.Name.text = cell.poi.name;
    cell.AdministrativeArea.text = cell.poi.administrativearea;
    
    if (cell.poi.Images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        PoiImageNSO *FirstImageItem = [cell.poi.Images firstObject];
        [cell.PoiKeyImage setImage:FirstImageItem.Image];
    }
    return cell;
}


/*
 created date:      03/05/2018
 last modified:     03/05/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *IDENTIFIER = @"SearchPoiCellId";
    
    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }

    PoiNSO *Poi = [self.poifiltereditems objectAtIndex:indexPath.row];
    
    if (self.Activity==nil) {
        /* open Poi view */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
        controller.delegate = self;
        controller.db = self.db;
        controller.PointOfInterest = Poi;
        controller.newitem = false;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
       
    } else {
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.db = self.db;
        controller.Activity = self.Activity;
        controller.Activity.project = self.Project;
        controller.Activity.poi = Poi;
     
        controller.transformed = self.transformed;
        controller.newitem = true;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              [self tableView:tableView deletePoi:indexPath];
                                              self.TableViewSearchPoiItems.editing = NO;
                                              
                                          }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
/*
 created date:      02/05/2018
 last modified:     02/05/2018
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deletePoi:(NSIndexPath *)indexPath  {
    if ([self.db DeletePoi:[self.poifiltereditems objectAtIndex:indexPath.row]] == true)
    {
        [self LoadPoiData];
    }
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.SearchBarPoi resignFirstResponder];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchTableList {
    NSString *searchData = self.SearchBarPoi.text;
    
    for (PoiNSO *poi in self.poiitems) {
            
        NSRange range = [poi.searchstring rangeOfString:searchData options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [self.poifiltereditems addObject:poi];
        }
            
    }
}
/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    NSLog(@"searchBarTextDidEndEditing");
    self.isSearching = NO;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",self.isSearching);
    
    if ([searchText length] ==0) {
        [self RefreshPoiFilteredData];
        self.isSearching = NO;
    } else {
        //Remove all objects first.
        [self.poifiltereditems removeAllObjects];
    
        
        self.isSearching = YES;
        [self searchTableList];
        
        [self.TableViewSearchPoiItems reloadData];
    }
}



/*
 created date:      30/04/2018
 last modified:     03/05/2018
 remarks:
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self RefreshPoiFilteredData];
}



/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
    if([segue.identifier isEqualToString:@"ShowNewActivity"]){
        ActivityDataEntryVC *controller = (ActivityDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.Activity = self.Activity;

        if ([sender isKindOfClass: [PoiListCell class]]) {
            PoiListCell *cell = (PoiListCell *) sender;
            PoiImageNSO *img = [cell.poi.Images firstObject];
            img.Image = cell.PoiKeyImage.image;
            controller.Activity.poi = cell.poi;
            controller.Activity.project = self.Project;
        }
        controller.transformed = self.transformed;
        controller.newitem = true;
    } else
    */
    if([segue.identifier isEqualToString:@"ShowPoiLocator"]){
        LocatorVC *controller = (LocatorVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
    }
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}


@end
