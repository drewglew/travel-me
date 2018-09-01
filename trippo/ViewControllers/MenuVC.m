//
//  MenuVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC () <PoiSearchDelegate, ProjectListDelegate>
@property RLMNotificationToken *notification;
@end

@implementation MenuVC
int Adjustment;

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      27/04/2018
 last modified:     31/08/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.TripImageDictionary = [[NSMutableDictionary alloc] init];

    self.selectedtripitems = [[NSMutableArray alloc] init];
    
    Adjustment = self.ViewFeature.frame.size.width + 10;
    self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant - Adjustment;

    self.ViewFeature.hidden = true;
    
    self.SetReload = false;
    
    self.alltripitems = [TripRLM allObjects];

    [self LocateTripContent];
    [self LoadSupportingData];
    
    __weak typeof(self) weakSelf = self;
    
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LocateTripContent];
        [weakSelf LoadSupportingData];
    }];
}

/*
 created date:      18/08/2018
 last modified:     31/08/2018
 remarks:
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.ActivityView stopAnimating];
    [self LoadFeaturedPoi];
}



/*
 created date:      15/08/2018
 last modified:     19/08/2018
 remarks:
 */
-(void)LocateTripContent {
    // 1=past/last; 2=now; 3=new (optional); 4=future/next; 5=new (optional)
    
    NSDate* currentDate = [NSDate date];

    /* last trip 0/1 */
    TripRLM* lasttrip = [[TripRLM alloc] init];

    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"enddt" ascending:YES];
    [self.alltripitems sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    NSDate* tripdt = nil;
    
    for (TripRLM* trip in self.alltripitems) {
        // past item
        if([currentDate compare: trip.enddt] == NSOrderedDescending ) {
            if (tripdt==nil) {
                tripdt = trip.enddt;
                lasttrip = [[TripRLM alloc] initWithValue:trip];
                
            } else if ([tripdt compare: trip.enddt] == NSOrderedAscending) {
                lasttrip = [[TripRLM alloc] initWithValue:trip];
                lasttrip.itemgrouping = [NSNumber numberWithInt:1];
                tripdt = trip.enddt;
            }
        }
    }
    
    if (lasttrip.itemgrouping==[NSNumber numberWithInt:1]) {
        [self.selectedtripitems addObject:lasttrip];
    }

    /* active trip 0/1:M */
    bool found_active = false;
    for (TripRLM* trip in self.alltripitems) {
        // current item
        if ([currentDate compare: trip.startdt] == NSOrderedDescending && [currentDate compare: trip.enddt] == NSOrderedAscending) {
            trip.itemgrouping = [NSNumber numberWithInt:2];
            [self.selectedtripitems addObject:trip];
            found_active = true;
        }
    }
    /* optional new if no active trip found */
    if (!found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:3];
        emptytrip.name = @"Start creating!";
        [self.selectedtripitems addObject:emptytrip];
    }
    
    sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
    [self.alltripitems sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    /* next trip 0/1 */
    tripdt = nil;
    TripRLM* nexttrip = [[TripRLM alloc] init];

    for (TripRLM* trip in self.alltripitems) {
        // nexttrip item
        if([currentDate compare: trip.startdt] == NSOrderedAscending ) {
            if (tripdt==nil) {
                tripdt = trip.startdt;
                nexttrip = [[TripRLM alloc] initWithValue:trip];
                nexttrip.itemgrouping = [NSNumber numberWithInt:4];
            } else if ([tripdt compare: trip.startdt] == NSOrderedDescending) {
                nexttrip = [[TripRLM alloc] initWithValue:trip];
                nexttrip.itemgrouping = [NSNumber numberWithInt:4];
                tripdt = trip.startdt;
            }
        }
    }

    if (nexttrip.itemgrouping == [NSNumber numberWithInt:4]) {
        [self.selectedtripitems addObject:nexttrip];
    }
    
     /* optional new if active trip found */
    if (found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:5];;
        emptytrip.name = @"Start planning!";
        [self.selectedtripitems addObject:emptytrip];
    }
}

/*
 created date:      15/08/2018
 last modified:     31/08/2018
 remarks:
 */
-(void) LoadSupportingData {
    /* 1. Get Images from file. */
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (TripRLM *trip in self.selectedtripitems) {
        if (trip.images.count==1) {
            ImageCollectionRLM *imgobject = [trip.images firstObject];
            NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
            NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
            [self.TripImageDictionary setObject:[UIImage imageWithData:pngData] forKey:trip.key];
        } else {
            [self.TripImageDictionary setObject:[UIImage imageNamed:@"Project"] forKey:trip.key];
        }
    }
    [self.CollectionViewPreviewPanel reloadData];
}

/*
 created date:      18/08/2018
 last modified:     31/08/2018
 remarks:
 */
-(void) LoadFeaturedPoi {
    
    RLMResults *poicollection = [PoiRLM allObjects];
    
    if (poicollection.count==0) { return; }
    int featuredIndex = arc4random_uniform((int)poicollection.count);
    self.FeaturedPoi = [poicollection objectAtIndex:featuredIndex];
    
    NSURL *url = [self applicationDocumentsDirectory];
    
    NSData *pngData;
    
    if (self.FeaturedPoi.images.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        RLMResults *filteredArray = [self.FeaturedPoi.images objectsWithPredicate:predicate];
        
        ImageCollectionRLM *keyimgobject;
        
        if (filteredArray.count==0) {
            keyimgobject = [self.FeaturedPoi.images firstObject];
        } else {
            keyimgobject = [filteredArray firstObject];
        }
        NSURL *imagefile = [url URLByAppendingPathComponent:keyimgobject.ImageFileReference];
        NSError *err;
        pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
        UIImage *image =[UIImage imageWithData:pngData];
        self.ImageViewFeaturedPoi.image = image;
        
    } else {
        self.ImageViewFeaturedPoi.image = [UIImage imageNamed:@"Poi"];
    }
    self.ViewFeature.hidden = false;
    [UIView animateWithDuration:1.0f animations:^{
        self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant + Adjustment;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"LoadFeaturedPoi %f",  self.FeaturedViewTrailingConstraint.constant);
        NSLog(@"LoadFeaturedPoi %f", self.ViewFeature.frame.size.width);
    }];
}



/*
 created date:      27/04/2018
 last modified:     18/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant - Adjustment;
    
    if([segue.identifier isEqualToString:@"ShowPoiList"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Project = nil;
        controller.Activity = nil;
        controller.realm = self.realm;
    } else if([segue.identifier isEqualToString:@"ShowProjectList"]){
        ProjectListVC *controller = (ProjectListVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
    } else if ([segue.identifier isEqualToString:@"ShowFeaturedPoi"]){
        /*
         */
        PoiDataEntryVC *controller= (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.FeaturedPoi;
        controller.readonlyitem = true;
        controller.realm = self.realm;
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
 last modified:     31/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ProjectListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    cell.ImageViewProject.image = [self.TripImageDictionary objectForKey:trip.key];
    
    cell.LabelProjectName.text = trip.name;
    
    
    if (trip.itemgrouping==[NSNumber numberWithInt:1]) {
        cell.LabelDateRange.text = @"Last";
        
    } else if (trip.itemgrouping==[NSNumber numberWithInt:2]) {
        cell.LabelDateRange.text = @"Active";
    } else if (trip.itemgrouping==[NSNumber numberWithInt:4]) {
        cell.LabelDateRange.text = @"Next";
    } else {
        cell.LabelDateRange.text = @"New";
    }
    return cell;
}


/*
 created date:      15/08/2018
 last modified:     31/08/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant - Adjustment;

    if (trip.itemgrouping==[NSNumber numberWithInt:3] || trip.itemgrouping==[NSNumber numberWithInt:5]) {
        ProjectDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ProjectDataEntryViewController"];
        controller.delegate = self;
        controller.Trip = [[TripRLM alloc] init];
        controller.newitem = true;
        controller.deleteitem = false;
        controller.realm = self.realm;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        controller.Trip = [self.selectedtripitems objectAtIndex:indexPath.row];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}



/*
 created date:      14/08/2018
 last modified:     31/08/2018
 remarks:           Scrolls to selected trip item.
 */
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath *indexPath;
    int index = 0;
    for (TripRLM *p in self.selectedtripitems) {
        if (p.itemgrouping==[NSNumber numberWithInt:2] || p.itemgrouping==[NSNumber numberWithInt:3]) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        } else if (p.itemgrouping==[NSNumber numberWithInt:4] && indexPath==nil) {
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

    
    self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant - Adjustment;
    
    [self.ActivityView startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
    controller.delegate = self;
    controller.Project = nil;
    controller.Activity = nil;
    controller.realm = self.realm;
    
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
