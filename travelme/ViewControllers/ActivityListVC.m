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
 last modified:     30/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadActivityData];
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
-(void) LoadActivityData {
    self.activityitems = [self.db GetActivityContent :nil :self.Project.key];
    //[self LoadSupportingData];
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
        //cell.LabelProjectName.text = @"";
        //cell.isNewAccessor = true;
        //cell.editButton.hidden = true;
        //cell.VisualEffectsViewBlur.hidden = true;*/
    } else {
        cell.ImageViewActivity.image = [UIImage imageNamed:@"Activity"];
        /*ProjectNSO *project = [self.projectitems objectAtIndex:indexPath.row];
        if (project.Image == nil) {
            cell.ImageViewProject.image = [UIImage imageNamed:@"Project"];
        } else {
            cell.ImageViewProject.image = project.Image;
        }
        cell.LabelProjectName.text = project.name;
        cell.VisualEffectsViewBlur.hidden = false;
        cell.isNewAccessor = false;
        if (self.editmode) {
            cell.editButton.hidden=false;
        } else {
            cell.editButton.hidden=true;
        }*/
    }
    return cell;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.activityitems.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
        controller.delegate = self;
        controller.db = self.db;
        controller.Activity = [self.activityitems objectAtIndex:indexPath.row];
        /* load Poi */
        controller.PointOfInterest = [[self.db GetPoiContent:controller.Activity.poi.key] firstObject];
        controller.newitem = false;
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
        controller.Project = self.Project;
        //controller.PointOfInterest = [[self.db GetPoiContent:controller.Activity.poi.key] firstObject];
    }
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
