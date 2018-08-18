//
//  MenuVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC () <PoiSearchDelegate, ProjectListDelegate>
@end

@implementation MenuVC


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
*/
-(void)CreateDb {
    [AppDelegateDef.Db CreateDb];
}
/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
-(void)DeleteDb {
    [AppDelegateDef.Db DeleteDb];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SetReload = false;
    self.alltripitems = [AppDelegateDef.Db GetProjectContent :nil];
    [self LocateTripContent];
    [self LoadSupportingData];
    [self LoadFeaturedPoi];
}

/*
 created date:      18/08/2018
 last modified:     18/08/2018
 remarks:
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.ActivityView stopAnimating];

    if (self.SetReload) {
        
        self.alltripitems = [AppDelegateDef.Db GetProjectContent :nil];
        [self LocateTripContent];
        [self LoadSupportingData];
        [self LoadFeaturedPoi];
        [self.CollectionViewPreviewPanel reloadData];
    } else {
        self.SetReload = true;
    }
}



/*
 created date:      15/08/2018
 last modified:     17/08/2018
 remarks:
 */

-(void)LocateTripContent {
    
    NSDate* currentDate = [NSDate date];
    self.selectedtripitems = [[NSMutableArray alloc] init];
    
    // 1=past/last 2=now 3=new (optional) 4=future/next 5=new (optional)
    
    /* last trip 0/1 */
    ProjectNSO* lasttrip = [[ProjectNSO alloc] init];
    NSDate* tripdt = nil;
    
    for (ProjectNSO* trip in self.alltripitems) {
        // past item
        if([currentDate compare: trip.enddt] == NSOrderedDescending ) {
            if (tripdt==nil) {
                tripdt = trip.enddt;
                lasttrip = trip;
            } else if ([tripdt compare: trip.enddt] == NSOrderedAscending) {
                lasttrip = trip;
                lasttrip.timeinverval = 1;
                tripdt = trip.enddt;
            }

        }
    }
    
    if (lasttrip.timeinverval==1) {
        [self.selectedtripitems addObject:lasttrip];
    }

    /* active trip 0/1:M */
    bool found_active = false;
    for (ProjectNSO* trip in self.alltripitems) {
        // current item
        if ([currentDate compare: trip.startdt] == NSOrderedDescending && [currentDate compare: trip.enddt] == NSOrderedAscending) {
            trip.timeinverval = 2;
            [self.selectedtripitems addObject:trip];
            found_active = true;
        }
    }
    /* optional new if no active trip found */
    if (!found_active) {
        ProjectNSO* emptytrip = [[ProjectNSO alloc] init];
        emptytrip.timeinverval = 3;
        emptytrip.name = @"Start creating!";
        [self.selectedtripitems addObject:emptytrip];
    }
    
    /* next trip 0/1 */
    tripdt = nil;
    ProjectNSO* nexttrip = [[ProjectNSO alloc] init];

    for (ProjectNSO* trip in self.alltripitems) {
        // nexttrip item
        if([currentDate compare: trip.startdt] == NSOrderedAscending ) {
            if (tripdt==nil) {
                tripdt = trip.startdt;
                nexttrip = trip;
                nexttrip.timeinverval = 4;
            } else if ([tripdt compare: trip.startdt] == NSOrderedDescending) {
                nexttrip = trip;
                nexttrip.timeinverval = 4;
                tripdt = trip.startdt;
            }
        }
    }

    if (nexttrip.timeinverval==4) {
        [self.selectedtripitems addObject:nexttrip];
    }
    
     /* optional new if active trip found */
    if (found_active) {
        ProjectNSO* emptytrip = [[ProjectNSO alloc] init];
        emptytrip.timeinverval = 5;
        emptytrip.name = @"Start creating!";
        [self.selectedtripitems addObject:emptytrip];
    }
    
}

/*
 created date:      15/08/2018
 last modified:     15/08/2018
 remarks:
 */
-(void) LoadSupportingData {
    /* 1. Get Images from file. */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (ProjectNSO *trip in self.selectedtripitems) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",trip.imagefilereference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        trip.Image = [UIImage imageWithData:pngData];
    }
}

/*
 created date:      18/08/2018
 last modified:     18/08/2018
 remarks:
 */
-(void) LoadFeaturedPoi {
   self.FeaturedPoi = [AppDelegateDef.Db GetFeaturedPoi];
    
    NSURL *url = [self applicationDocumentsDirectory];
    
    NSData *pngData;
    
    if (self.FeaturedPoi.Images.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        NSArray *filteredArray = [self.FeaturedPoi.Images filteredArrayUsingPredicate:predicate];
        
        PoiImageNSO *KeyImageItem;
        
        if (filteredArray.count==0) {
            KeyImageItem = [self.FeaturedPoi.Images firstObject];
        } else {
            KeyImageItem = [filteredArray firstObject];
        }
        
        NSURL *imagefile = [url URLByAppendingPathComponent:KeyImageItem.ImageFileReference];
        
        NSError *err;
        
        pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
        
        UIImage *image =[UIImage imageWithData:pngData];
        
        self.ImageViewFeaturedPoi.image = image;
        
    } else {
        self.ImageViewFeaturedPoi.image = [UIImage imageNamed:@"Poi"];
    }   
}



/*
 created date:      27/04/2018
 last modified:     18/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowPoiList"]){
        
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Project = nil;
        controller.Activity = nil;
    } else if([segue.identifier isEqualToString:@"ShowProjectList"]){
        ProjectListVC *controller = (ProjectListVC *)segue.destinationViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowFeaturedPoi"]){
        PoiDataEntryVC *controller= (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.FeaturedPoi;
        controller.readonlyitem = true;
    }
}



/*
 created date:      14/08/2018
 last modified:     15/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedtripitems.count;
}

/*
 created date:      14/08/2018
 last modified:     15/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ProjectListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];

    ProjectNSO *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    if (trip.Image == nil) {
        cell.ImageViewProject.image = [UIImage imageNamed:@"Project"];
    } else {
        cell.ImageViewProject.image = trip.Image;
    }
    
    cell.LabelProjectName.text = trip.name;
    
    
    if (trip.timeinverval==1) {
        cell.LabelDateRange.text = @"Last";
        
    } else if (trip.timeinverval==2) {
        cell.LabelDateRange.text = @"Active";
    } else if (trip.timeinverval==4) {
        cell.LabelDateRange.text = @"Next";
    } else {
        cell.LabelDateRange.text = @"New";
    }
    return cell;
}


/*
 created date:      15/08/2018
 last modified:     15/08/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectNSO *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (trip.timeinverval==3 || trip.timeinverval==5) {
        ProjectDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ProjectDataEntryViewController"];
        controller.delegate = self;
        controller.Project = [[ProjectNSO alloc] init];
        controller.newitem = true;
        controller.deleteitem = false;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.Project = [self.selectedtripitems objectAtIndex:indexPath.row];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}



/*
 created date:      14/08/2018
 last modified:     15/08/2018
 remarks:           Scrolls to selected trip item.
 */
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath *indexPath;
    int index = 0;
    for (ProjectNSO *p in self.selectedtripitems) {
        if (p.timeinverval==2 || p.timeinverval==3) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        } else if (p.timeinverval==4 && indexPath==nil) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        }
        index++;
    }
    if (indexPath!=nil) {
        [self.CollectionViewPreviewPanel scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
}

- (IBAction)ButtonFeaturedPoiPressed:(id)sender {
    
    
}

/*
 created date:      18/08/2018
 last modified:     18/08/2018
 remarks:           Opens up the POI search list view.  Activity view needs NSRunLoop command to get time to present it.
 */
- (IBAction)ButtonShowPoiListPressed:(id)sender {

    [self.ActivityView startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
    controller.delegate = self;
    controller.Project = nil;
    controller.Activity = nil;
    
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
    
    [self.ActivityView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didCreatePoiFromProject:(PoiNSO *)Object {
    
}

- (void)didUpdatePoi:(NSString *)Method :(PoiNSO *)Object {
    
}

@end
