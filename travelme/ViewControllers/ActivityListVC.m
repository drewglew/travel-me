//
//  ActivityListVC.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListVC.h"

@interface ActivityListVC ()

@end

@implementation ActivityListVC

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewActivities.delegate = self;
    self.LabelProject.text =  [NSString stringWithFormat:@"Activities for %@", self.Project.name];
    
    // Do any additional setup after loading the view.
}

/*
 created date:      30/04/2018
 last modified:     01/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
}

/*
 created date:      30/04/2018
 last modified:     01/05/2018
 remarks:
 */
-(void) LoadActivityData:(NSNumber*) State {
    
    self.activityitems = [self.db GetActivityListContentForState :self.Project.key :State];

    /* for each activity we need to show the image of the poi attached to it */
    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (ActivityNSO *activity in self.activityitems) {
        PoiImageNSO *imageitem = [activity.poi.Images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        imageitem.Image = [UIImage imageWithData:pngData];
    }
    
    
    [self.CollectionViewActivities reloadData];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activityitems.count + 1;;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.activityitems.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewActivity.image = [UIImage imageNamed:@"AddItem"];
        cell.VisualViewBlur.hidden = true;
        cell.LabelName.hidden = true;
    } else {
        cell.activity = [self.activityitems objectAtIndex:indexPath.row];
        if (self.SegmentState.selectedSegmentIndex==1) {
            if (cell.activity.activitystate== [NSNumber numberWithInt:0]) {
                // show blurred image of activity!
                cell.VisualViewBlur.hidden = false;
            } else {
                cell.VisualViewBlur.hidden = true;
            }
        } else {
            cell.VisualViewBlur.hidden = true;
        }
        cell.LabelName.hidden = false;
        cell.LabelName.text = cell.activity.name;
        PoiImageNSO *imageitem = [cell.activity.poi.Images firstObject];
        cell.ImageViewActivity.image = imageitem.Image;
    }
    return cell;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:  ImG todo
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger NumberOfItems = self.activityitems.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        //ActivityListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.db = self.db;
        controller.Activity = [self.activityitems objectAtIndex:indexPath.row];
        ActivityNSO *activity = [self.activityitems objectAtIndex:indexPath.row];
        PoiImageNSO *imageitem = [activity.poi.Images firstObject];
        controller.Activity.poi = [[self.db GetPoiContent:activity.poi.key] firstObject];
        [controller.Activity.poi.Images removeAllObjects];
        [controller.Activity.poi.Images addObject:imageitem];
        controller.Activity.project = self.Project;
        long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
        controller.newitem = false;
        if (selectedSegmentState == 1 && activity.activitystate == [NSNumber numberWithInt:0]) {
            // this is an activity item selected from the actual selection that is in fact an idea item.
            controller.transformed = true;
            controller.Activity.activitystate = [NSNumber numberWithInt:1];
            // how can we determine on destination controller what is a brand new item and a transformed item?  Do we need to?
        } else {
            controller.transformed = false;
        }
        
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
        
    }

}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewActivities.frame.size.width;
    float cellWidth = collectionWidth/3.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
    return size;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"ShowNewActivity"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.Activity = [[ActivityNSO alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.Project = self.Project;
    }
}

- (IBAction)ActivityStateChanged:(id)sender {
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           segue controls .
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}
@end
