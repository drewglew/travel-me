//
//  ActivityDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiSearchVC.h"

@interface PoiSearchVC ()
@property RLMNotificationToken *notification;
@end

@implementation PoiSearchVC

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      30/04/2018
 last modified:     10/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBarPoi.delegate = self;
    self.TableViewSearchPoiItems.delegate = self;
    self.TableViewSearchPoiItems.rowHeight = 100;
    
    self.SegmentCountries.selectedSegmentIndex=1;
    if (self.TripItem == nil) {
        // we are arriving directly from the menu
        //[self.SegmentPoiFilterList setTitle:@"Unused" forSegmentAtIndex:0];
        self.SegmentCountries.selectedSegmentIndex=1;
        self.SegmentCountries.enabled = false;
        
    } else {
        // project is available
        self.SegmentCountries.selectedSegmentIndex=0;

        NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
        RLMResults <ActivityRLM*> *activities = [[ActivityRLM objectsWhere:@"tripkey = %@",self.TripItem.key] distinctResultsUsingKeyPaths:keypaths];
        
        self.countries = [[NSMutableArray alloc] init];
        for (ActivityRLM *activityobj in activities) {
            PoiRLM *poi = [PoiRLM objectForPrimaryKey:activityobj.poikey];
            bool found=false;
            for (NSString *country in self.countries) {
                if ([country isEqualToString:poi.countrycode]) {
                    found=true;
                    break;
                }
            }
            if (!found) {
                [self.countries addObject:poi.countrycode];
            }
        }
    }
    
    self.ButtonNew.layer.cornerRadius = 25;
    self.ButtonNew.clipsToBounds = YES;
    self.ButtonBack.layer.cornerRadius = 25;
    
    self.ButtonBack.clipsToBounds = YES;
    self.ButtonBack.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    
    self.ButtonResetFilter.layer.cornerRadius = 25;
    self.ButtonResetFilter.clipsToBounds = YES;
    self.ButtonResetFilter.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.ButtonFilter.layer.cornerRadius = 25;
    self.ButtonFilter.clipsToBounds = YES;
    self.ButtonFilter.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);

    /* user selected specific option from startup view */
    __weak typeof(self) weakSelf = self;
    
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf RefreshPoiFilteredData:true];
        [weakSelf.TableViewSearchPoiItems reloadData];
    }];

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
    
    
    
    [self LoadPoiBackgroundImageData];
    
    [self RefreshPoiFilteredData :true];

    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.CollectionViewTypes addGestureRecognizer:lpgr];
    
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.CollectionViewTypes];
    
    NSIndexPath *indexPath = [self.CollectionViewTypes indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
        TypeNSO *type = [self.PoiTypes objectAtIndex:indexPath.row];
        
        NSNumber *categoryid = type.categoryid;
        
        for (TypeNSO *type in self.PoiTypes) {
            if (type.categoryid == categoryid) {
                type.selected = true;
            } else {
                type.selected = false;
            }
        }
        
        [self RefreshPoiFilteredData:false];
     
    }
}



/*
 created date:      11/06/2018
 last modified:     10/08/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UISearchBar appearance].tintColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]; [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]}];
    
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

/*
 created date:      03/05/2018
 last modified:     10/09/2018
 remarks:
 */
-(void)RefreshPoiFilteredData :(bool) UpdateTypes {
    
    self.poifilteredcollection = [PoiRLM allObjects];
    
    if (self.SegmentPoiFilterList.selectedSegmentIndex != 1) {
        /* get distinct poi items from activities */
        NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
        RLMResults<ActivityRLM*> *used = [[ActivityRLM allObjects] distinctResultsUsingKeyPaths:keypaths];
        
        NSMutableArray *poiitems = [[NSMutableArray alloc] init];
        for (ActivityRLM *usedPois in used) {
            [poiitems addObject:usedPois.poikey];
        }
        NSSet *typeset = [[NSSet alloc] initWithArray:poiitems];
        
        if (self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
            NSLog(@"unused");

            self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"NOT (key IN %@)",typeset]];
            
        } else if (self.SegmentPoiFilterList.selectedSegmentIndex == 2) {
            NSLog(@"used");

            self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"key IN %@",typeset]];
            
        }
    }

    if (self.TripItem != nil && self.SegmentCountries.selectedSegmentIndex == 0) {
        NSSet *projectcountries = [NSSet setWithArray:self.countries];
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"countrycode IN %@",projectcountries]];
    }
    
    if (self.isSearching) {
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"searchstring CONTAINS %@",self.SearchBarPoi.text]];
    }
    
    
    if (UpdateTypes) {
        
        NSCountedSet* countedSet = [[NSCountedSet alloc] init];
        
        for (PoiRLM* poi in self.poifilteredcollection) {
            [countedSet addObject:poi.categoryid];
        }
        
        self.PoiTypes = [[NSMutableArray alloc] init];
        
        for (id item in countedSet)
        {
            TypeNSO *type = [[TypeNSO alloc] init];
            type.occurances = [NSNumber numberWithInteger:[countedSet countForObject:item]];
            type.categoryid = item;
            u_long number = [item unsignedLongValue];
            type.imagename = [self.TypeItems objectAtIndex: number];
            type.selected = true;
            [self.PoiTypes addObject:type];
        }
    
    } else {
        // here we filter on existing types instead..

        NSMutableArray *types = [[NSMutableArray alloc] init];
        for (TypeNSO *type in self.PoiTypes) {
            if (type.selected) {
                [types addObject:type.categoryid];
            }
        }
        
        NSSet *typeset = [[NSSet alloc] initWithArray:types];
        
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"categoryid IN %@",typeset]];
    }

    
    
    [self.LabelCounter setText:[NSString stringWithFormat:@"%lu Items", (unsigned long)self.poifilteredcollection.count]];
    
    [self.TableViewSearchPoiItems reloadData];
    
    [self.CollectionViewTypes reloadData];
    
}


/*
 created date:      30/04/2018
 last modified:     18/08/2018
 remarks:
 */
-(void) LoadPoiBackgroundImageData {
    if (AppDelegateDef.PoiBackgroundImageDictionary.count==0) {
        NSURL *url = [self applicationDocumentsDirectory];

        NSData *pngData;
        
        RLMResults <PoiRLM*> *allPoiObjects = [PoiRLM allObjects];
        
        for (PoiRLM *poi in allPoiObjects) {
            
            if (poi.images.count > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
                RLMResults *filteredArray = [poi.images objectsWithPredicate:predicate];
                ImageCollectionRLM *imgobject;
                if (filteredArray.count==0) {
                    imgobject = [poi.images firstObject];
                } else {
                    imgobject = [filteredArray firstObject];
                }
                NSURL *imagefile = [url URLByAppendingPathComponent:imgobject.ImageFileReference];
                NSError *err;
                pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
                UIImage *image;
                if (pngData==nil) {
                    image = [UIImage imageNamed:@"Poi"];
                } else {
                    image =[UIImage imageWithData:pngData];
                }
                
                CGSize tablecellsize = CGSizeMake(self.TableViewSearchPoiItems.frame.size.width , self.TableViewSearchPoiItems.rowHeight); // set the width and height
                CGSize imagesize = CGSizeMake(image.size.width , image.size.height); // set the width and height
                
               
                CGRect CropRect = CGRectMake((imagesize.width/2) - (tablecellsize.width/2), (imagesize.height/2) - (tablecellsize.height/2), tablecellsize.width, tablecellsize.height);

                
                [AppDelegateDef.PoiBackgroundImageDictionary setObject:[self croppIngimageByImageName:image toRect:CropRect] forKey:poi.key];
            }
        }
    }
}




/*
 created date:      15/07/2018
 last modified:     15/07/2018
 remarks:   Scale image to size passed in
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
 created date:      13/09/2018
 last modified:     13/09/2018
 remarks:   Crop image with size passed in
 */
- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
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
    return self.poifilteredcollection.count;
}


/*
 created date:      30/04/2018
 last modified:     31/08/2018
 remarks:
 */
- (PoiListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPoiCellId"];

    
    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchPoiCellId"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }

    PoiRLM *poi = [self.self.poifilteredcollection objectAtIndex:indexPath.row];
    
    cell.poi = poi;    
    cell.Name.attributedText=[[NSAttributedString alloc]
                                          initWithString:poi.name
                                          attributes:@{
                                                       NSStrokeWidthAttributeName: @-2.0,
                                                       NSStrokeColorAttributeName:[UIColor blackColor],
                                                       NSForegroundColorAttributeName:[UIColor whiteColor]
                                                       }
                                          ];
    
    
    cell.AdministrativeArea.text = poi.administrativearea;
    
    cell.ImageCategory.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:[cell.poi.categoryid integerValue]]];
    
    
    if (poi.images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage imageNamed:@"Poi"]];
    } else {
        /* locate key image */
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        //RLMResults<ImageCollectionRLM*> *filteredArray = [poi.images objectsWithPredicate :predicate];
        //ImageCollectionRLM *imgobject = [filteredArray firstObject];
        [cell.PoiKeyImage setImage:[AppDelegateDef.PoiBackgroundImageDictionary objectForKey:poi.key]];
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

    PoiRLM *Poi = [self.self.poifilteredcollection objectAtIndex:indexPath.row];
    
    if (self.Activity==nil) {
        /* open Poi view */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
        controller.delegate = self;
        controller.realm = self.realm;
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
        controller.realm = self.realm;
        controller.Poi = Poi;
        controller.Trip = self.TripItem;
        //controller.Activity.poi = Poi;
        controller.deleteitem = false;
        controller.transformed = self.transformed;
        controller.newitem = true;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
 created date:      10/09/2018
 last modified:     10/09/2018
 remarks:           User can only delete unused Poi items
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL edit = NO;
    if(self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
        edit = YES;
    }
    return edit;
}



/*
 created date:      02/05/2018
 last modified:     10/09/2018
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
 last modified:     10/09/2018
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deletePoi:(NSIndexPath *)indexPath  {

    PoiRLM *item = [self.poifilteredcollection objectAtIndex:indexPath.row];
    [self.realm transactionWithBlock:^{
        [self.realm deleteObject:item];
    }];

    NSLog(@"delete called!");
}

/*
 created date:      30/04/2018
 last modified:     11/08/2018
 remarks:
 */
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewSearchPoiItems.frame.size.width, self.FilterOptionHeightConstraint.constant)];
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
 remarks:           TODO merge the search with the filter.  how best to do?
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",self.isSearching);
    
    if ([searchText length] ==0) {
        self.isSearching = NO;
    } else {
        self.isSearching = YES;
    }
    [self RefreshPoiFilteredData :true];
}



/*
 created date:      30/04/2018
 last modified:     03/05/2018
 remarks:
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self RefreshPoiFilteredData :true];
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
        controller.realm = self.realm;
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
                    controller.PointOfInterest = [self.poifilteredcollection objectAtIndex:indexPath.row];
                    controller.realm = self.realm;
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
    //[self LoadPoiData];
    [self RefreshPoiFilteredData :true];
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (IBAction)SegmentPoiCountriesFilterChanged:(id)sender {
    
    [self RefreshPoiFilteredData :true];
    
}




/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.PoiTypes.count;
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TypeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TypeCellId" forIndexPath:indexPath];
    TypeNSO *item = [self.PoiTypes objectAtIndex:indexPath.row];
    [cell.TypeImageView setImage:[UIImage imageNamed:item.imagename]];
    cell.LabelOccurances.text = [NSString stringWithFormat:@"%@", item.occurances];
    cell.selected = item.selected;
    cell.ImageViewChecked.hidden = !item.selected;
    return cell;
}


/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    TypeNSO *item = [self.PoiTypes objectAtIndex:indexPath.row];
    item.selected = !item.selected;
    [self RefreshPoiFilteredData :false];
}



/*
 created date:      11/08/2018
 last modified:     12/08/2018
 remarks:           Only sets all category filters to selected
 */
- (IBAction)FilterResetPressed:(id)sender {
    
    for (TypeNSO *type in self.PoiTypes) {
        type.selected = true;
    }
    self.SearchBarPoi.text = @"";
    self.isSearching = false;
    
    [self RefreshPoiFilteredData:true];
    
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (IBAction)FilterPressed:(id)sender {
    
    [self.view layoutIfNeeded];
    if (self.FilterOptionHeightConstraint.constant==70) {
        [UIView animateWithDuration:0.75 animations:^{
            self.FilterOptionHeightConstraint.constant=300;
            self.ButtonResetFilter.hidden = false;
            [self.ButtonFilter setImage:[UIImage imageNamed:@"Close-Pane"] forState:UIControlStateNormal];
            //self.ButtonMore.transform = CGAffineTransformMakeRotation(M_PI);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            
        }];
        
    } else {
        [UIView animateWithDuration:0.75 animations:^{
            self.FilterOptionHeightConstraint.constant=70;
            self.ButtonResetFilter.hidden = true;
            [self.ButtonFilter setImage:[UIImage imageNamed:@"Filter"] forState:UIControlStateNormal];
            //self.ButtonMore.transform = CGAffineTransformMakeRotation(-2*M_PI);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
}

/*
 created date:      12/08/2018
 last modified:     13/09/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
    NSURL *url = [self applicationDocumentsDirectory];
    
    NSData *pngData;
    //[self RefreshPoiFilteredData:true];
    if (Object.images.count>0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        RLMResults *filteredArray = [Object.images objectsWithPredicate:predicate];
        ImageCollectionRLM *imgobject;
        if (filteredArray.count==0) {
            imgobject = [Object.images firstObject];
        } else {
            imgobject = [filteredArray firstObject];
        }
        NSURL *imagefile = [url URLByAppendingPathComponent:imgobject.ImageFileReference];
        NSError *err;
        pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
        UIImage *image;
        if (pngData!=nil) {
            image =[UIImage imageWithData:pngData];
        }
        else {
            image =[UIImage imageNamed:@"Poi"];
        }
        CGSize tablecellsize = CGSizeMake(self.TableViewSearchPoiItems.frame.size.width , self.TableViewSearchPoiItems.rowHeight); // set the width and height
        CGSize imagesize = CGSizeMake(image.size.width , image.size.height); // set the width and height
        
        CGRect CropRect = CGRectMake((imagesize.width/2) - (tablecellsize.width/2), (imagesize.height/2) - (tablecellsize.height/2), tablecellsize.width, tablecellsize.height);

        [AppDelegateDef.PoiBackgroundImageDictionary setObject:[self croppIngimageByImageName:image toRect:CropRect] forKey:Object.key];
    }
}

/*
 created date:      11/06/2018
 last modified:     12/08/2018
 remarks:  Called when new Poi item has been created.
 */
- (void)didCreatePoiFromProjectPassThru :(PoiNSO*)Object {
    [self.SegmentCountries setSelectedSegmentIndex:1];
    [self.SegmentPoiFilterList setSelectedSegmentIndex:0];
    [self.SearchBarPoi setText:Object.name];
    [self searchBar:_SearchBarPoi textDidChange:Object.name];
}


- (void)didCreatePoiFromProject:(NSString *)Key {
    
}

/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:  TODO, make sure it is optimal and not called multiple times!
 */
- (void)didUpdateActivityImages :(bool) ForceUpdate {
    [self.delegate didUpdateActivityImages :true];
}


@end
