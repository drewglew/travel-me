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
 last modified:     08/08/2018
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
    
    self.ButtonNew.layer.cornerRadius = 25;
    self.ButtonNew.clipsToBounds = YES;
    self.ButtonBack.layer.cornerRadius = 25;
    self.ButtonBack.clipsToBounds = YES;
    
    self.poiitems = [[NSMutableArray alloc] init];
    self.poifiltereditems = [[NSMutableArray alloc] init];

    self.TypeItems = @[@"Cat-Accomodation",
                       @"Cat-Airport",
                       @"Cat-Astronaut",
                       @"Cat-Beer",
                       @"Cat-Bike",
                       @"Cat-Bridge",
                       @"Cat-CarHire",
                       @"Cat-Casino",
                       @"Cat-Church",
                       @"Cat-City",
                       @"Cat-Club",
                       @"Cat-Concert",
                       @"Cat-FoodWine",
                       @"Cat-Historic",
                       @"Cat-House",
                       @"Cat-Lake",
                       @"Cat-Lighthouse",
                       @"Cat-Metropolis",
                       @"Cat-Misc",
                       @"Cat-Monument",
                       @"Cat-Museum",
                       @"Cat-Nature",
                       @"Cat-Office",
                       @"Cat-Restaurant",
                       @"Cat-Scenary",
                       @"Cat-Sea",
                       @"Cat-Ship",
                       @"Cat-Shopping",
                       @"Cat-Ski",
                       @"Cat-Sports",
                       @"Cat-Theatre",
                       @"Cat-ThemePark",
                       @"Cat-Train",
                       @"Cat-Trek",
                       @"Cat-Venue",
                       @"Cat-Zoo"
                       ];
    
    [self LoadPoiData];
    
    //[self.SearchBarPoi setImage:[UIImage imageNamed:@"SearchWhite"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    //self.SearchBarPoi.  backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0];

    

    
}
/*
 created date:      11/06/2018
 last modified:     10/08/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//     if (self.Project == nil) {
//         [self LoadPoiData];
//     }
    [UISearchBar appearance].tintColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]; [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]}];
    
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
    [self.LabelCounter setText:[NSString stringWithFormat:@"%lu Items", (unsigned long)self.poifiltereditems.count]];
    [self.TableViewSearchPoiItems reloadData];
}


/*
 created date:      30/04/2018
 last modified:     21/05/2018
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
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
            NSArray *filteredArray = [poi.Images filteredArrayUsingPredicate:predicate];
            PoiImageNSO *KeyImageItem = [filteredArray firstObject];

            NSURL *imagefile = [url URLByAppendingPathComponent:KeyImageItem.ImageFileReference];
            
            NSError *err;
            
            pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
            
            UIImage *image =[UIImage imageWithData:pngData];
            CGSize size = CGSizeMake(self.TableViewSearchPoiItems.frame.size.width , self.TableViewSearchPoiItems.rowHeight); // set the width and height
            KeyImageItem.Image = [self resizeImage:image imageSize:size];
        }
    }
 
    [self.poifiltereditems removeAllObjects];
    [self.poifiltereditems addObjectsFromArray: self.poiitems];
    [self.LabelCounter setText:[NSString stringWithFormat:@"%lu Items", (unsigned long)self.poifiltereditems.count]];
    [self.TableViewSearchPoiItems reloadData];
}

/*
 created date:      15/07/2018
 last modified:     15/07/2018
 remarks:
 */

-(UIImage *)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
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
 last modified:     21/05/2018
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
    
    cell.ImageCategory.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:[cell.poi.categoryid integerValue]]];
    
    
    if (poi.Images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        /* locate key image */
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        NSArray *filteredArray = [poi.Images filteredArrayUsingPredicate:predicate];
        PoiImageNSO *KeyImageItem = [filteredArray firstObject];
        [cell.PoiKeyImage setImage:KeyImageItem.Image];
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
    [self.LabelCounter setText:[NSString stringWithFormat:@"%lu Items", (unsigned long)self.poifiltereditems.count]];
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
 last modified:     16/07/2018
 remarks:           segue controls.  We need to work here next - get selection Project==null
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowPoiLocator"]){
        LocatorVC *controller = (LocatorVC *)segue.destinationViewController;
        controller.delegate = self;
        if (self.Project == nil) {
            controller.fromproject = false;
        }
        else {
            controller.fromproject = true;
        }
    } else if([segue.identifier isEqualToString:@"ShowNearby"]){
        NearbyListingVC *controller = (NearbyListingVC *)segue.destinationViewController;
        controller.delegate = self;
        
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[PoiListCell class]]) {
                    PoiListCell *cell = (PoiListCell*)cellView;
                    NSIndexPath *indexPath = [self.TableViewSearchPoiItems indexPathForCell:cell];
                    controller.PointOfInterest = [self.poifiltereditems objectAtIndex:indexPath.row];
                }
            }
        }
    } else if([segue.identifier isEqualToString:@"ShowNearbyMe"]){
        NearbyListingVC *controller = (NearbyListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = nil;
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

/*
 created date:      11/06/2018
 last modified:     11/06/2018
 remarks:  Called when new Poi item has been created.
 */
- (void)didCreatePoiFromProjectPassThru :(NSString*)Key {
    self.SegmentPoiFilterList.selectedSegmentIndex = 1;

    [self.SearchBarPoi setText:Key];
    [self LoadPoiData];
    [self searchBar:_SearchBarPoi textDidChange:Key];
    

}



- (void)didCreatePoiFromProject:(NSString *)Key {
    
}


- (IBAction)ButtonOpenAppleMaps:(id)sender {
}

/*
 created date:      15/07/2018
 last modified:     15/07/2018
 remarks:
 */
- (void)didUpdatePoi :(bool)IsUpdated {
    [self LoadPoiData];
}




- (IBAction)ButtonWiki:(id)sender {
}
- (IBAction)ButtonUpdate:(id)sender {
}
@end
