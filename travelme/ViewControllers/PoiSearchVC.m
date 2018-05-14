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

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      30/04/2018
 last modified:     14/05/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBarPoi.delegate = self;
    self.TableViewSearchPoiItems.delegate = self;
    self.TableViewSearchPoiItems.rowHeight = 100;
    
    if (self.Project == nil) {
        // we are arriving directly from the menu
        [self.SegmentPoiFilterList setTitle:@"Unused" forSegmentAtIndex:0];
        
    } else {
        // project is available
        [self.SegmentPoiFilterList setTitle:@"Project Countries" forSegmentAtIndex:0];
        self.countries = [AppDelegateDef.Db GetProjectCountries :self.Project.key];
        
    }
    
    self.poiitems = [[NSMutableArray alloc] init];
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


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

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
 last modified:     14/05/2018
 remarks:
 */
-(void) LoadPoiData {
    
    if (self.Project == nil) {
        self.poiitems = [AppDelegateDef.Db GetPoiContent :nil :nil :nil];
        if (self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
            self.poiitems = [AppDelegateDef.Db GetPoiContent :nil :nil :@"unused"];
        } else {
            self.poiitems = [AppDelegateDef.Db GetPoiContent :nil :nil :nil];
        }
    } else {
        if (self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
            self.poiitems = [AppDelegateDef.Db GetPoiContent :nil :self.countries :nil];
        } else {
            self.poiitems = [AppDelegateDef.Db GetPoiContent :nil :nil :nil];
        }
    }
        
    NSURL *url = [self applicationDocumentsDirectory];

    NSData *pngData;
    for (PoiNSO *poi in self.poiitems) {
        
        if (poi.Images.count > 0) {

            PoiImageNSO *FirstImageItem = [poi.Images firstObject];
            NSURL *imagefile = [url URLByAppendingPathComponent:FirstImageItem.ImageFileReference];
            
            //FirstImageItem.Image = [UIImage imageWithContentsOfFile:[imagefile absoluteString]];
            NSError *err;
            
            pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
           
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

    
    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPoiCellId"];

    
    if (cell == nil) {
        
        /*
         *   Actually create a new cell (with an identifier so that it can be dequeued).
         */
        
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchPoiCellId"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }

    PoiNSO *poi = [self.poifiltereditems objectAtIndex:indexPath.row];
    
    cell.poi = poi;
    cell.Name.text = poi.name;
    cell.AdministrativeArea.text = poi.administrativearea;
    
    if (poi.Images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        PoiImageNSO *FirstImageItem = [poi.Images firstObject];
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
        controller.PointOfInterest = Poi;
        controller.newitem = false;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
       
    } else {
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.Activity.project = self.Project;
        controller.Activity.poi = Poi;
        controller.deleteitem = false;
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
    if ([AppDelegateDef.Db DeletePoi:[self.poifiltereditems objectAtIndex:indexPath.row]] == true)
    {
        [self LoadPoiData];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewSearchPoiItems.frame.size.width, 70)];
    return footerView;
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
    
    if([segue.identifier isEqualToString:@"ShowPoiLocator"]){
        LocatorVC *controller = (LocatorVC *)segue.destinationViewController;
        controller.delegate = self;
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

/*
 created date:      14/05/2018
 last modified:     14/05/2018
 remarks:
 */
- (IBAction)SegmentPoiFilterChanged:(id)sender {
    [self LoadPoiData];
}

@end
