//
//  ActivityListVC.m
//  travelmegetActivityImage
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListVC.h"
#import <TwitterKit/TWTRComposer.h>
#import <TwitterKit/TWTRTwitter.h>
@import UserNotifications;

@interface ActivityListVC ()
@property RLMNotificationToken *notification;
@property NSIndexPath *LongGesturedPressedSelectedIndexPath;
@end

@implementation ActivityListVC
CGFloat ActivityListFooterFilterHeightConstant;
CGFloat NumberOfCellsInRow = 3.0f;
CGFloat LastScale = 0.0f;
@synthesize delegate;

/*
 created date:      30/04/2018
 last modified:     10/06/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    self.CollectionViewActivities.delegate = self;
    self.TableViewDiary.delegate = self;
    self.editmode = false;
    
    
    if (![ToolBoxNSO HasTopNotch]) {
        self.HeaderViewHeightConstraint.constant = 70.0f;
    }
    
    
    // Do any additional setup after loading the view.
    if (self.Trip.itemgrouping==[NSNumber numberWithInt:1]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"%@ - Activities in Last Trip", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:4]) {
        self.LabelProject.text =  [NSString stringWithFormat:@"Next Trip in %@", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:2]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"Active Trip in %@", self.Trip.name];
    } else {
         self.LabelProject.text =  [NSString stringWithFormat:@"Activities for %@", self.Trip.name];
    }
    
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
    [self LoadActivityImageData];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadActivityData :[NSNumber numberWithInteger:weakSelf.SegmentState.selectedSegmentIndex]];
        if (weakSelf.CollectionViewActivities.hidden) {
            [weakSelf.TableViewDiary reloadData];
        } else {
            [weakSelf.CollectionViewActivities reloadData];
        }
    }];

    ActivityListFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;

    self.TableViewDiary.rowHeight = 125;
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.CollectionViewActivities addGestureRecognizer:longPressRecognizer];
    
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self.CollectionViewActivities addGestureRecognizer:pinch];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    self.TableViewDiary.sectionFooterHeight = 50;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 50)];
    self.TableViewDiary.tableHeaderView = headerView;
    self.tweetview = false;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    self.TableViewDiary.allowsSelection = NO;
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.TableViewDiary.allowsSelection = YES;
}

-(NSDate *)dateWithOutTime:(NSDate *)datDate
{
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear  fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}



/*
 created date:      10/06/2019
 last modified:     11/06/2019
 remarks:
 */
-(void)onPinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales.
        LastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        double CurrentScale = [gestureRecognizer scale];
        double pinchscale = CurrentScale;

        if (pinchscale  < 1.0f) {
            pinchscale *= 5;
        }

        if (NumberOfCellsInRow==5.0f && pinchscale > 0.5f && CurrentScale > LastScale) {
            NumberOfCellsInRow=4.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==4.0f && pinchscale > 1.5f && CurrentScale > LastScale) {
            NumberOfCellsInRow=3.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==3.0f && pinchscale > 3.0f && CurrentScale > LastScale) {
            NumberOfCellsInRow=2.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==2.0f && pinchscale > 4.0f && CurrentScale > LastScale) {
            NumberOfCellsInRow=1.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==4.0f && pinchscale < 1.5f && CurrentScale < LastScale) {
            NumberOfCellsInRow=5.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==3.0f && pinchscale < 3.00f && CurrentScale < LastScale) {
            NumberOfCellsInRow=4.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==2.0f && pinchscale < 4.00f && CurrentScale < LastScale) {
            NumberOfCellsInRow=3.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        } else if (NumberOfCellsInRow==1.0f && pinchscale < 5.00f && CurrentScale < LastScale) {
            NumberOfCellsInRow=2.0f;
            [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
        }
        LastScale = [gestureRecognizer scale];  // Store the previous. scale factor for the next pinch gesture call
    }
    
}

/*
 created date:      27/09/2018
 last modified:     27/09/2018
 remarks:
 */
-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture
{
    if (NumberOfCellsInRow<=3.0f) {
        
        NSInteger NumberOfItems = self.activitycollection.count + 1;

        if (pGesture.state == UIGestureRecognizerStateBegan)
        {
            CGPoint touchPoint = [pGesture locationInView:self.CollectionViewActivities];
            self.LongGesturedPressedSelectedIndexPath = [self.CollectionViewActivities indexPathForItemAtPoint:touchPoint];
            if (self.LongGesturedPressedSelectedIndexPath != nil) {
                if (self.LongGesturedPressedSelectedIndexPath.row == NumberOfItems -1) {
                    return;
                }
                //Handle the long press on row
                // NSLog(@"%ld row pressed",(long)self.LongGesturedPressedSelectedIndexPath.row);
                ActivityListCell *cell= (ActivityListCell*)[self.CollectionViewActivities cellForItemAtIndexPath:self.LongGesturedPressedSelectedIndexPath ];
                cell.ViewDateInfo.hidden = false;
            }
        }
        if (pGesture.state == UIGestureRecognizerStateEnded)
        {
            if (self.LongGesturedPressedSelectedIndexPath != nil) {
                //Handle the long press on row
                // NSLog(@"%ld row unpressed",(long)self.LongGesturedPressedSelectedIndexPath.row);
                ActivityListCell *cell= (ActivityListCell*)[self.CollectionViewActivities cellForItemAtIndexPath:self.LongGesturedPressedSelectedIndexPath ];
                cell.ViewDateInfo.hidden = true;
                
            }
        }
    }
}

/*
 created date:      30/04/2018
 last modified:     17/03/2019
 remarks:           Tweet option included in selection of cells.
 */
-(void) LoadActivityData:(NSNumber*) State {
    
    // NSLog(@"completed loadactivity code block");
    
    NSDateFormatter *DateIdentityFormatter = [[NSDateFormatter alloc] init];
    [DateIdentityFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSMutableDictionary *dataset = [[NSMutableDictionary alloc] init];
    
    /* obtain the planned activities, both planned and actual activities are interested in this */
    NSString *IdentityStartDate = [[NSString alloc] init];
    NSString *IdentityEndDate = [[NSString alloc] init];

    self.AllActivitiesInTrip = [ActivityRLM objectsWhere:@"tripkey = %@", self.Trip.key];
    
    NSString *whereClause = @"state==0";
    
    if (State==[NSNumber numberWithLong:0] || !self.tweetview) {
        
        if (self.tweetview) {
            whereClause = [NSString stringWithFormat:@"%@ and IncludeInTweet==1", whereClause];
        }
        
        RLMResults<ActivityRLM*> *plannedactivities = [self.AllActivitiesInTrip objectsWhere:whereClause];
        
        for (ActivityRLM* planned in plannedactivities) {
            [dataset setObject:planned forKey:planned.key];
        }
        self.IdentityStartDt  = [plannedactivities minOfProperty:@"startdt"];
        self.IdentityEndDt = [plannedactivities minOfProperty:@"enddt"];
    }
    
    /* next only for actual activities we search for those too and replace using dictionary any of them */
    if (State==[NSNumber numberWithLong:1]) {
        
        whereClause = @"state==1";
        if (self.tweetview) {
            whereClause = [NSString stringWithFormat:@"%@ and IncludeInTweet==1", whereClause];
            [dataset removeAllObjects];
        }

        RLMResults<ActivityRLM*> *actualactivities = [self.AllActivitiesInTrip objectsWhere:whereClause];
        bool found=false;
        for (ActivityRLM* actual in actualactivities) {
            [dataset setObject:actual forKey:actual.key];
            found = true;
        }
        if (found) {
            self.IdentityStartDt  = [actualactivities minOfProperty:@"startdt"];
            self.IdentityEndDt = [actualactivities minOfProperty:@"enddt"];
        }
    }
    
    NSArray *temp2 = [[NSArray alloc] initWithArray:[dataset allValues]];

    NSSortDescriptor *sortDescriptorState = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:NO];
    NSSortDescriptor *sortDescriptorStartDt = [[NSSortDescriptor alloc] initWithKey:@"startdt"
                                                 ascending:YES];
    
    temp2 = [temp2 sortedArrayUsingDescriptors:@[sortDescriptorState,sortDescriptorStartDt]];
    self.activitycollection = [NSMutableArray arrayWithArray:temp2];

    if (self.IdentityStartDt == nil ||  [self.IdentityStartDt compare:self.Trip.startdt] == NSOrderedDescending) {
        self.IdentityStartDt = self.Trip.startdt;
    }

    if (self.IdentityEndDt == nil ||  [self.IdentityEndDt compare:self.Trip.enddt] == NSOrderedAscending) {
        self.IdentityEndDt = self.Trip.enddt;
    }

    if (self.tweetview) {
        return;
    }
    /* diary collection - not including Tweet complexity */
    IdentityStartDate = [DateIdentityFormatter stringFromDate:self.IdentityStartDt];
    IdentityEndDate = [DateIdentityFormatter stringFromDate:self.IdentityEndDt];
        
    NSMutableArray *diaryactivties = [[NSMutableArray alloc] init];
    
    for (ActivityRLM *activity in self.activitycollection) {
        ActivityRLM *a = activity;
        a.identitystartdate = [DateIdentityFormatter stringFromDate:activity.startdt];
        a.identityenddate = [DateIdentityFormatter stringFromDate:activity.enddt];
        [diaryactivties addObject:a];
    }

    self.sectionheaderdaystitle = [[NSMutableArray alloc] init];
    self.diarycollection = [[NSMutableArray alloc] init];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;

    NSDateFormatter *FullDateFormatter = [[NSDateFormatter alloc] init];
    [FullDateFormatter setDateFormat:@"EEEE, dd MMMM, YYYY"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *StartDt = [dateFormatter dateFromString:IdentityStartDate];
    NSDate *EndDt = [dateFormatter dateFromString:IdentityEndDate];

    int DayIndex = 0;
    while ([StartDt compare:EndDt] == NSOrderedAscending || [StartDt compare:EndDt] == NSOrderedSame) {
        
        IdentityStartDate = [DateIdentityFormatter stringFromDate:StartDt];
        IdentityEndDate = [DateIdentityFormatter stringFromDate:EndDt];
        
        DayIndex ++;
        DiaryDatesNSO *dd = [[DiaryDatesNSO alloc] init];

        dd.daytitle = [NSString stringWithFormat:@"Day %d - %@", DayIndex, [FullDateFormatter stringFromDate:StartDt]];
        dd.startdt = StartDt;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identitystartdate = %@", IdentityStartDate];
        NSArray *itemsinday = [diaryactivties filteredArrayUsingPredicate:predicate];
        
        itemsinday = [itemsinday sortedArrayUsingDescriptors:@[sortDescriptorStartDt]];
        
        [self.diarycollection addObject:itemsinday];
        
        StartDt = [currentCalendar dateByAddingComponents:oneDay toDate:StartDt options:0];
        dd.enddt = StartDt;
        [self.sectionheaderdaystitle addObject:dd];
    }
    // NSLog(@"completed loadactivity code block");
}

/*
 created date:      01/09/2018
 last modified:     21/03/2019
 remarks:  Load all Activity images for Trip
 */
-(void)LoadActivityImageData {
    /* for each activity we need to show the image of the poi attached to it */
    /* load images from file - TODO make sure we locate them all */
    
    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey==%@",self.Trip.key];
    for (ActivityRLM *activityobj in activities) {
        [self getActivityImage :activityobj];
    }
    // NSLog(@"completed");
}

/*
 created date:      21/03/2019
 last modified:     30/03/2019
 remarks:           Load single Activity image for Trip - TODO optimize this.
                    use thumbnail image if it exists, else - create it (the activity data entry point will
                    also need to do some management - when it deletes an activity or a key image delete its thumbnail
 */
-(void)getActivityImage :(ActivityRLM*) activity {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    RLMResults *filteredResults;
    ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
    
    CGSize CellSize = CGSizeMake(self.CollectionViewActivities.collectionViewLayout.collectionViewContentSize.height, self.CollectionViewActivities.collectionViewLayout.collectionViewContentSize.height);

    filteredResults = [activity.images objectsWithPredicate:predicate];
    if (filteredResults.count>0) {
        imgobject = [filteredResults firstObject];
    } else {
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activity.poikey];
        filteredResults = [poiobject.images objectsWithPredicate:predicate];
        if (filteredResults.count==0) {
            imgobject = [poiobject.images firstObject];
        } else {
            imgobject = [filteredResults firstObject];
        }
    }

    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData==nil) {
        if (activity.state == [NSNumber numberWithInteger:0]) {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Planning"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
                image = nil;
            }
        } else {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Activity"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image  forKey:activity.compondkey];
                image = nil;
            }
        }
    } else {
        @autoreleasepool {
            UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageWithData:pngData]  toFitInSize:CellSize];
            [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
            image = nil;
        }
        
    }
    // NSLog(@"%@",activity.compondkey);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([ToolBoxNSO HasTopNotch]) {
        return CGSizeMake(0, 50);
    }
    else{
        return CGSizeMake(0, 50);
    }
}

/*
 created date:      30/04/2018
 last modified:     31/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activitycollection.count + 1;;
}

/*
 created date:      30/04/2018
 last modified:     31/03/2019
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityListCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
    
    cell.contentView.hidden = false;
    
    NSDateFormatter *TimePlusDayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [TimePlusDayOfWeekFormatter setDateFormat:@"HH:mm, EEEE"];
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd MMM YYYY"];
    
    NSInteger NumberOfItems = self.activitycollection.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        if (self.tweetview) {
            cell.contentView.hidden = true;
        }
        cell.ImageViewActivity.image = [UIImage imageNamed:@"AddItem"];
        [cell.ImageViewActivity setTintColor: [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        cell.ImageConstraint = [cell.ImageConstraint updateMultiplier:0.6];
        cell.VisualViewBlur.hidden = true;
        cell.ViewOverlay.hidden = true;
        cell.ImageBlurBackground.hidden = true;
        cell.ImageBlurBackgroundBottomHalf.hidden = true;
        cell.ViewActiveBadge.hidden = true;
        cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
    } else {
        
        if (!self.editmode) {
            cell.ViewOverlay.hidden = false;
        } else {
            cell.ViewOverlay.hidden = true;
        }
        
        cell.activity = [self.activitycollection objectAtIndex:indexPath.row];
        cell.ImageConstraint = [cell.ImageConstraint updateMultiplier:0.992];
        
        /* setup startdt popup that shows on longpress */
        if (cell.activity.startdt!=nil) {
            cell.LabelStartTimePlusWeekDay.text = [NSString stringWithFormat:@"%@",[TimePlusDayOfWeekFormatter stringFromDate:cell.activity.startdt]];
            cell.LabelStartDate.text = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:cell.activity.startdt]];
        } else {
            cell.LabelStartTimePlusWeekDay.text = @"";
            cell.LabelStartDate.text = @"";
        }
        
         /* setup enddt & approx duration popup that shows on longpress */
        NSComparisonResult resultSameStartEndDt = [cell.activity.startdt compare:cell.activity.enddt];
        
        if (cell.activity.enddt!=nil && resultSameStartEndDt != NSOrderedSame ) {
            cell.LabelEndTimePlusWeekDay.text = [NSString stringWithFormat:@"%@",[TimePlusDayOfWeekFormatter stringFromDate:cell.activity.enddt]];
            cell.LabelEndDate.text = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:cell.activity.enddt]];
            cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference :cell.activity.startdt :cell.activity.enddt :@""];
        } else {
            cell.LabelEndTimePlusWeekDay.text = @"";
            cell.LabelEndDate.text = @"";
            cell.LabelDuration.text = @"";
        }

        RLMResults <ActivityRLM*> *activitySet = [self.AllActivitiesInTrip objectsWhere:[NSString stringWithFormat:@"key = '%@'",cell.activity.key]];
        NSNumber *CountOfActivitiesInSet = [NSNumber numberWithLong:activitySet.count];
        
        if (self.SegmentState.selectedSegmentIndex == 1) {
            
            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2] || self.tweetview) {
                cell.ImageViewBookmark.image = nil;
            } else {
                ActivityRLM *single = [activitySet firstObject];
                if (single.state == [NSNumber numberWithInteger:1]) {
                    [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Yellow"]];
                } else {
                    /* Activity not set as active */
                    [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Blue"]];
                }
            }

            if (cell.activity.state == [NSNumber numberWithInteger:0]) {
                if (self.tweetview) {
                    cell.contentView.hidden = true;
                    
                } else {
                    cell.ButtonDelete.hidden = true;
                    cell.VisualViewBlur.hidden = false;
                }
            } else {
                if (self.tweetview) {
                    cell.ButtonDelete.hidden = true;
                } else {
                    cell.ButtonDelete.hidden = false;
                }
                cell.VisualViewBlur.hidden = true;
            }
           
            if ([cell.activity.startdt compare: cell.activity.enddt] == NSOrderedSame && cell.activity.startdt!=nil) {
                // only show badge when activity is Actual.
                if (cell.activity.state == [NSNumber numberWithInteger:1]) {
                    cell.ViewActiveBadge.layer.cornerRadius = 35;
                    cell.ViewActiveBadge.layer.masksToBounds = YES;
                    cell.ViewActiveBadge.transform = CGAffineTransformMakeRotation(.34906585);
                    cell.ViewActiveBadge.hidden = false;
                } else  {
                    cell.ViewActiveBadge.hidden = true;
                }
            } else {
                cell.ViewActiveBadge.hidden = true;
            }
            

            
 
        } else {

            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2]) {
                cell.ImageViewBookmark.image = nil;
            } else {
                if (self.tweetview) {
                    cell.ImageViewBookmark.image = nil;
                } else {
                    [cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Blue"]];
                }
            }
            
            cell.VisualViewBlur.hidden = true;
            if (self.tweetview) {
                cell.ButtonDelete.hidden = true;
            } else {
                cell.ButtonDelete.hidden = false;
            }
            cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
            cell.ViewActiveBadge.hidden = true;
        }

        NSArray *TypeItems = @[
                @"Cat-Accomodation",
                @"Cat-Airport",
                @"Cat-Astronaut",
                @"Cat-Bakery",
                @"Cat-Beer",
                @"Cat-Bike",
                @"Cat-Bridge",
                @"Cat-CarHire",
                @"Cat-CarPark",
                @"Cat-Casino",
                @"Cat-Cave",
                @"Cat-Church",
                @"Cat-Cinema",
                @"Cat-City",
                @"Cat-CityPark",
                @"Cat-Climbing",
                @"Cat-Club",
                @"Cat-Sea",
                @"Cat-Concert",
                @"Cat-FoodWine",
                @"Cat-Football",
                @"Cat-Forest",
                @"Cat-Golf",
                @"Cat-Historic",
                @"Cat-House",
                @"Cat-Lake",
                @"Cat-Lighthouse",
                @"Cat-Metropolis",
                @"Cat-Misc",
                @"Cat-Monument",
                @"Cat-Museum",
                @"Cat-NationalPark",
                @"Cat-Nature",
                @"Cat-Office",
                @"Cat-PetrolStation",
                @"Cat-Photography",
                @"Cat-Restaurant",
                @"Cat-River",
                @"Cat-Rugby",
                @"Cat-Safari",
                @"Cat-Scenary",
                @"Cat-School",
                @"Cat-Ship",
                @"Cat-Shopping",
                @"Cat-Ski",
                @"Cat-Sports",
                @"Cat-Swimming",
                @"Cat-Tennis",
                @"Cat-Theatre",
                @"Cat-ThemePark",
                @"Cat-Tower",
                @"Cat-Train",
                @"Cat-Trek",
                @"Cat-Venue",
                @"Cat-Village",
                @"Cat-Windmill",
                @"Cat-Zoo"
        ];
                               
        
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:cell.activity.poikey];
        
        cell.ImageViewTypeOfPoi.image = [UIImage imageNamed:[TypeItems objectAtIndex:[poiobject.categoryid integerValue]]];

        if (!self.editmode || indexPath.row == NumberOfItems -1) {
             cell.ViewOverlay.hidden = false;
        } else {
            cell.ViewOverlay.hidden = true;
        }
       
        
        cell.ImageBlurBackground.hidden = false;
        //cell.ImageBlurBackgroundBottomHalf.hidden = false;
        
        if ([self.ActivityImageDictionary objectForKey:cell.activity.compondkey] == nil) {
            [self getActivityImage :cell.activity];
        }
        
        cell.ImageViewActivity.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
        
        if (self.tweetview) {
            //[cell.ViewOverlay setBackgroundColor:[UIColor whiteColor]];
            
            //cell.ViewOverlay.layer.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0].CGColor;
            cell.ViewPoiType.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
        } else {
            //[cell.ViewOverlay setBackgroundColor:[UIColor clearColor]];
            //cell.ViewOverlay.layer.backgroundColor = [UIColor clearColor].CGColor;
            cell.ImageBlurBackground.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
            cell.ImageBlurBackgroundBottomHalf.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
            cell.ViewPoiType.backgroundColor = [UIColor lightGrayColor];
        }
        
        //UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:14.0];
        UIFont *font = [UIFont systemFontOfSize:16.0];
        
        if (NumberOfCellsInRow >= 3.0f) {
            font = [UIFont systemFontOfSize:12.0];
            
            if (NumberOfCellsInRow > 3.0f) {
                if (self.editmode == 0) {
                    cell.ButtonDelete.hidden = true;
                    if (NumberOfCellsInRow == 5.0f) {
                        cell.ViewPoiType.hidden = true;
                    } else {
                        cell.ViewPoiType.hidden = false;
                    }
                } else {
                    cell.ButtonDelete.hidden = false;
                    cell.ViewPoiType.hidden = false;
                }
            }
        } else {
            if (self.editmode == 0) {
                cell.ButtonDelete.hidden = false;
                cell.ViewPoiType.hidden = false;
            }
        }
        
        NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor colorWithRed:35.0f/255.0f green:35.0f/255.0f blue:35.0f/255.0f alpha:1.0], NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:cell.activity.name attributes:attributes];
        cell.LabelName.attributedText = string;
        
    }
    return cell;
}


/*
 created date:      30/04/2018
 last modified:     11/06/2019
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewActivities.frame.size.width;
    double cellWidth = collectionWidth / NumberOfCellsInRow;
    double rounded = round (cellWidth * 100.0) / 100.0;
    CGSize size = CGSizeMake(rounded, rounded);
    return size;
}

/*
 created date:      30/04/2018
 last modified:     21/02/2019
 remarks:  ImG todo
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger NumberOfItems = self.activitycollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        
        ActivityRLM *activity = [self.activitycollection objectAtIndex:indexPath.row];
        
        controller.Poi = [PoiRLM objectForPrimaryKey:activity.poikey];
        controller.PoiImage = [self RetrievePoiImageItem :controller.Poi];
        
        controller.Trip = self.Trip;
        long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
        controller.newitem = false;
        if (selectedSegmentState == 1 && activity.state == [NSNumber numberWithInteger:0]) {
            // this is an activity item selected from the actual selection that is in fact an idea item.
            ActivityRLM *new = [[ActivityRLM alloc] init];
            new.key = activity.key;
            new.state = [NSNumber numberWithInt:1];
            new.compondkey = [NSString stringWithFormat:@"%@~1",activity.key];
            new.name = activity.name;
            new.tripkey = activity.tripkey;
            new.poikey = activity.poikey;
            new.createddt = [NSDate date];
            new.modifieddt = [NSDate date];
            new.geonotification = activity.geonotification;
            new.geonotifycheckout = activity.geonotifycheckout;
            new.geonotifycheckindt = activity.geonotifycheckindt;
            new.geonotifycheckoutdt = activity.geonotifycheckoutdt;
            controller.Activity = new;
            controller.transformed = true;
            // how can we determine on destination controller what is a brand new item and a transformed item?  Do we need to?
        } else {
            controller.Activity = [self.activitycollection objectAtIndex:indexPath.row];
            controller.transformed = false;
        }
        controller.deleteitem = false;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
 created date:      20/02/2019
 last modified:     23/02/2019
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionheaderdaystitle.count;
}

/*
 created date:      20/02/2019
 last modified:     23/02/2019
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *temp = self.diarycollection[section];
    return temp.count;
}

/*
 created date:      17/03/2019
 last modified:     17/03/2019
 remarks:
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)];
    
    headerView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    
    UILabel* title = [[UILabel alloc] init];
    title.frame = CGRectMake(10, 10, tableView.frame.size.width - 50, 20);
    
    DiaryDatesNSO *dd = self.sectionheaderdaystitle[section];

    title.textColor = [UIColor colorWithRed:71.0f/255.0f green:71.0f/255.0f blue:71.0f/255.0f alpha:1.0];
    title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    title.text = dd.daytitle;
    title.textAlignment = NSTextAlignmentLeft;
    
    // 4. Add the label to the header view
    [headerView addSubview:title];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(tableView.frame.size.width - 40.0, 3.5, 35.0, 35.0); // x,y,width,height
    button.tag = section;
    
    [button setImage:[UIImage imageNamed:@"AddItem"] forState:UIControlStateNormal];
    [button setTintColor: [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    [button addTarget:self action:@selector(sectionHeaderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    return headerView;
}

/*
 created date:      23/02/2019
 last modified:     23/02/2019
 remarks:
 */
-(void)sectionHeaderButtonPressed :(id)sender {
    [self performSegueWithIdentifier:@"ShowNewActivityFromDiary" sender:sender];
}



/*
 created date:      20/02/2019
 last modified:     24/03/2019
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityDiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityDiaryCellId"];
    
    cell.activity = [[self.diarycollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (self.SegmentState.selectedSegmentIndex==1 && cell.activity.state==[NSNumber numberWithInteger:0]) {
        cell.TextFieldStartDt.enabled = false;
        cell.TextFieldEndDt.enabled = false;
        [cell.LabelName setTextColor:[UIColor lightGrayColor]];
        //cell.DurationBar.backgroundColor = [UIColor lightGrayColor];
        [cell.LabelDuration setTextColor:[UIColor lightGrayColor]];
        cell.ButtonDelete.hidden = true;
    } else if (self.SegmentState.selectedSegmentIndex==1)  {
        cell.TextFieldStartDt.enabled = true;
        cell.TextFieldEndDt.enabled = true;
        [cell.LabelName setTextColor:[UIColor colorWithRed:71.0f/255.0f green:71.0f/255.0f blue:71.0f/255.0f alpha:1.0]];
        if ( [cell.activity.startdt compare:cell.activity.enddt] == NSOrderedSame) {
            // This is ongoing...
            cell.LabelDuration.text = @"active!";
        } else {
            cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference: cell.activity.startdt :cell.activity.enddt :@""];
            [cell.LabelDuration setTextColor:[UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
        }
        cell.ButtonDelete.hidden = false;
    } else {
        cell.TextFieldStartDt.enabled = true;
        cell.TextFieldEndDt.enabled = true;
        [cell.LabelName setTextColor:[UIColor colorWithRed:71.0f/255.0f green:71.0f/255.0f blue:71.0f/255.0f alpha:1.0]];
        cell.ButtonDelete.hidden = false;
        //cell.DurationBar.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference: cell.activity.startdt :cell.activity.enddt :@""];
        [cell.LabelDuration setTextColor:[UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
    }

    cell.LabelName.text = cell.activity.name;
    cell.TextFieldStartDt.text = [ToolBoxNSO FormatPrettyTime :cell.activity.startdt];
    cell.TextFieldStartDt.delegate = self;
    cell.TextFieldEndDt.text = [ToolBoxNSO FormatPrettyTime :cell.activity.enddt];
    cell.TextFieldEndDt.delegate = self;
    
    cell.datePickerStart.date = cell.activity.startdt;
    //minimum date..
    cell.datePickerStart.minimumDate = self.IdentityStartDt;
    cell.datePickerStart.maximumDate  = cell.datePickerEnd.date;
    
    cell.datePickerEnd.date = cell.activity.enddt;
    cell.datePickerEnd.minimumDate = cell.datePickerStart.date;
    //maximum date..
    cell.datePickerEnd.maximumDate  = self.IdentityEndDt;
    
    cell.indexPathForCell = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
-(bool) textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.TableViewDiary.allowsSelection) {
        return true;
    } else {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.TableViewDiary];
        NSIndexPath *indexPath = [self.TableViewDiary indexPathForRowAtPoint:buttonPosition];
        ActivityDiaryCell *cell = [self.TableViewDiary cellForRowAtIndexPath:indexPath];
        if ([cell.TextFieldStartDt isFirstResponder] || [cell.TextFieldEndDt isFirstResponder]) {
            return true;
        }
    }
    return false;
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.TableViewDiary];
    NSIndexPath *indexPath = [self.TableViewDiary indexPathForRowAtPoint:buttonPosition];
    ActivityDiaryCell *cell = [self.TableViewDiary cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES animated:NO];
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.TableViewDiary];
    NSIndexPath *indexPath = [self.TableViewDiary indexPathForRowAtPoint:buttonPosition];
    ActivityDiaryCell *cell = [self.TableViewDiary cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
}

/*
created date:      22/02/2019
last modified:     24/02/2019
remarks:           table view with sections.
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
    controller.delegate = self;
    controller.realm = self.realm;

    ActivityRLM *activity = [[self.diarycollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    controller.Poi = [PoiRLM objectForPrimaryKey:activity.poikey];
    controller.PoiImage = [self RetrievePoiImageItem :controller.Poi];
    
    controller.Trip = self.Trip;
    long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
    controller.newitem = false;
    if (selectedSegmentState == 1 && activity.state == [NSNumber numberWithInteger:0]) {
        // this is an activity item selected from the actual selection that is in fact an idea item.
        ActivityRLM *new = [[ActivityRLM alloc] init];
        new.key = activity.key;
        new.state = [NSNumber numberWithInt:1];
        new.compondkey = [NSString stringWithFormat:@"%@~1",activity.key];
        new.name = activity.name;
        new.tripkey = activity.tripkey;
        new.poikey = activity.poikey;
        new.createddt = [NSDate date];
        new.modifieddt = [NSDate date];
        new.startdt = activity.startdt;
        new.enddt = activity.enddt;
        new.geonotification = activity.geonotification;
        new.geonotifycheckout = activity.geonotifycheckout;
        new.geonotifycheckindt = activity.geonotifycheckindt;
        new.geonotifycheckoutdt = activity.geonotifycheckoutdt;
        controller.Activity = new;
        controller.transformed = true;
    } else {
        controller.Activity =  activity;
        controller.transformed = false;
    }
    controller.deleteitem = false;
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
}

/*
 created date:      05/09/2018
 last modified:     29/09/2018
 remarks:  ImG
 */
-(UIImage*) RetrievePoiImageItem :(PoiRLM*) poi {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    UIImage *image = [[UIImage alloc] init];
    if (poi.images.count>0) {
        ImageCollectionRLM *imgobject = [[poi.images objectsWhere:@"KeyImage==1"] firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            image = [UIImage imageNamed:@"Poi"];
        } else {
            image = [UIImage imageWithData:pngData];
        }
    } else {
        image = [UIImage imageNamed:@"Poi"];
    }
    return image;
}



/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == ActivityListFooterFilterHeightConstant){
        // NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithSegmentConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithSegmentConstraint.constant == 0.0f){
        // NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = ActivityListFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

/*
 created date:      30/04/2018
 last modified:     24/03/2019
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"ShowNewActivity"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = [[ActivityRLM alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.state = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.TripItem = self.Trip;
        controller.realm = self.realm;
     
    } else if([segue.identifier isEqualToString:@"ShowNewActivityFromDiary"]){
        UIButton * button=(UIButton*)sender;
        DiaryDatesNSO *dd = self.sectionheaderdaystitle[button.tag];
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = [[ActivityRLM alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.state = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.Activity.startdt = dd.startdt;
        controller.Activity.enddt = dd.enddt;
        controller.TripItem = self.Trip;
        controller.realm = self.realm;
    
    } else if([segue.identifier isEqualToString:@"ShowSchedule"]) {
        ScheduleVC *controller = (ScheduleVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.activityitems = self.activityitems;
        controller.Trip = self.Trip;
        controller.realm = self.realm;
        controller.ActivityState = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    
    } else if([segue.identifier isEqualToString:@"ShowDeleteActivity"]) {
        [self DeleteActivity :sender];
        
    } else if ([segue.identifier isEqualToString:@"ShowDeleteActivityFromDiaryView"]) {
        [self DeleteActivity :sender];
    
    } else if([segue.identifier isEqualToString:@"ShowProjectPaymentList"]) {
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        /* here we add something new */
        controller.realm = self.realm;
        controller.TripItem = self.Trip;
        // we need the trip image..
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        ImageCollectionRLM *image = [self.Trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData!=nil) {
            controller.headerImage = [UIImage imageWithData:pngData];
        } else {
            controller.headerImage = [UIImage imageNamed:@"Project"];
        }
        controller.ActivityItem = nil;
        controller.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    }
}


/*
 created date:      24/03/2019
 last modified:     07/04/2019
 remarks:           segue controls .
 */
-(void)DeleteActivity: (id)sender {
    
    ActivityRLM *ActivityToDelete = [[ActivityRLM alloc] init];
    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ActivityListCell class]]  || [cellView isKindOfClass:[ActivityDiaryCell class]]) {
                ActivityListCell *cell = (ActivityListCell*)cellView;
                ActivityToDelete = cell.activity;
            }
        }
    }
    
    if (ActivityToDelete!=nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete Activity\n%@", ActivityToDelete.name] message:@"Are you sure you want to remove this actvity from current trip?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      
                                                                      [self RemoveGeoNotification :true :ActivityToDelete];
                                                                      [self RemoveGeoNotification :false :ActivityToDelete];
                                                                      
                                                                      
                                                                      [self.realm beginWriteTransaction];
                                                                      [self.realm deleteObject:ActivityToDelete];
                                                                      [self.realm commitWriteTransaction];
                                                                      
                                                                      
                                                                  });
                                                              }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Canel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 // do nothing..
                                                                 
                                                             }];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
 created date:      29/03/2019
 last modified:     29/03/2019
 remarks:
 */
-(void) RemoveGeoNotification :(bool) NotifyOnEntry :(ActivityRLM*) activity {
    NSString *identifier;
    
    if (NotifyOnEntry) {
        identifier = [NSString stringWithFormat:@"CHECKIN~%@", activity.compondkey];
    } else {
        identifier = [NSString stringWithFormat:@"CHECKOUT~%@", activity.compondkey];
    }
    
    NSArray *pendingNotification = [NSArray arrayWithObjects:identifier, nil];
    
    
    [AppDelegateDef.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:pendingNotification];
}



- (IBAction)ActivityStateChanged:(id)sender {
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
   
    if (self.TableViewDiary.hidden == true) {
        [self.CollectionViewActivities reloadData];
    } else {
        [self.TableViewDiary reloadData];
    }
}

- (IBAction)SwitchEditModeChanged:(id)sender {
        self.editmode = !self.editmode;
    [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
    

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
 created date:      08/09/2018
 last modified:     16/02/2019
 remarks:
 */
- (void)didUpdateActivityImages :(bool)ForceUpdate {
    [self LoadActivityImageData];
}

- (IBAction)ShowDatePressed:(id)sender {
    // NSLog(@"TOUCHED");
}

- (IBAction)RemoveDatePressedUp:(id)sender {
    // NSLog(@"UNTOUCHED");
}

/*
 created date:      20/02/2019
 last modified:     17/03/2019
 remarks:
 */
- (IBAction)SwapMainViewPressed:(id)sender {
    
    if (self.TableViewDiary.hidden == true) {
        self.ButtonTweet.hidden = true;
        self.TableViewDiary.hidden = false;
        [self.TableViewDiary reloadData];
        self.CollectionViewActivities.hidden = true;
        [self.ButtonSwapMainView setImage:[UIImage imageNamed:@"ActivityPhotoView"] forState:UIControlStateNormal];
    } else {
        self.ButtonTweet.hidden = false;
        self.TableViewDiary.hidden = true;
        [self.CollectionViewActivities reloadData];
        self.CollectionViewActivities.hidden = false;
        [self.ButtonSwapMainView setImage:[UIImage imageNamed:@"ActivityDiaryView"] forState:UIControlStateNormal];
    }
}


/*
 created date:      30/03/2019
 last modified:     31/03/2019
 remarks:
 */
- (UIImage *)imageWithCollectionView {
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(self.CollectionViewActivities.contentSize, NO, 0.0);
    {
        CGPoint savedContentOffset = self.CollectionViewActivities.contentOffset;
        CGRect savedFrame = self.CollectionViewActivities.frame;
        
        self.CollectionViewActivities.contentOffset = CGPointZero;
        self.CollectionViewActivities.frame = CGRectMake(0, 0, self.CollectionViewActivities.contentSize.width, self.CollectionViewActivities.contentSize.height);
        
        [self.CollectionViewActivities.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.CollectionViewActivities.contentOffset = savedContentOffset;
        self.CollectionViewActivities.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    return image;
}


/*
 created date:      15/03/2019
 last modified:     31/03/2019
 remarks:           Added completion block as image rendered too soon after reload data.
                    CustomCollectionView is custom subclass of UICollectionView.
                    https://stackoverflow.com/questions/16071503/how-to-tell-when-uitableview-has-completed-reloaddata
 */
- (IBAction)tweetButtonPressed:(id)sender {
    /* tweet break selected */
    
    self.tweetview = true;
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
    [self.CollectionViewActivities reloadDataWithCompletion:^{
        
        [self.CollectionViewActivities layoutIfNeeded];
        
        UIImage *image;
        image = [self imageWithCollectionView];
        
        CGRect newRect = [self cropRectForImage:image];
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, newRect);
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        
        NSString *TripType = @"highlights";
        
        if (self.SegmentState.selectedSegmentIndex == 0) {
            TripType = @"itinerary";
        }
        [composer setText:[NSString stringWithFormat:@"%@ trip %@, generated in @TrippoApp ",self.Trip.name, TripType]];
        [composer setImage:image];
        [composer showFromViewController:self completion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            } else {
                NSLog(@"Sending Tweet");
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tweetview = false;
                [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
                [self.CollectionViewActivities reloadData];
            });
        }];

    }];
}

/*
 created date:      17/03/2019
 last modified:     17/03/2019
 remarks:           stolen from stackoverflow
 */
- (CGRect)cropRectForImage:(UIImage *)image {
    
    CGImageRef cgImage = image.CGImage;
    CGContextRef context = [self createARGBBitmapContextFromImage:cgImage];
    if (context == NULL) return CGRectZero;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(context, rect, cgImage);
    
    unsigned char *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    //Filter through data and look for non-transparent pixels.
    u_long lowX = width;
    u_long lowY = height;
    u_long highX = 0;
    u_long highY = 0;
    if (data != NULL) {
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                u_long pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */;
                if (data[pixelIndex] != 0) { //Alpha value is not zero; pixel is not transparent.
                    if (x < lowX) lowX = x;
                    if (x > highX) highX = x;
                    if (y < lowY) lowY = y;
                    if (y > highY) highY = y;
                }
            }
        }
        free(data);
    } else {
        return CGRectZero;
    }
    return CGRectMake(lowX, lowY, highX-lowX, highY-lowY);
}

/*
 created date:      17/03/2019
 last modified:     17/03/2019
 remarks:           stolen from stackoverflow - used internally
 */
- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    u_long bitmapByteCount;
    u_long bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return NULL;
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL) free (bitmapData);
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease(colorSpace);
    
    return context;
}


@end
