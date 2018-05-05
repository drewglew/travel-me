//
//  TripListVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectListVC.h"

@interface ProjectListVC ()

@end

@implementation ProjectListVC
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewProjects.delegate = self;
    self.editmode = false;
    // Do any additional setup after loading the view.
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadProjectData];
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(void) LoadProjectData {
    self.projectitems = [self.db GetProjectContent :nil];
    [self LoadSupportingData];
    [self.CollectionViewProjects reloadData];
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
-(void) LoadSupportingData {
    /* 1. Get Images from file. */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    for (ProjectNSO *project in self.projectitems) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",project.imagefilereference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        project.Image = [UIImage imageWithData:pngData];
    }
    /* 2. Get Number of activities & maybe (duration of activities) */
    for (ProjectNSO *project in self.projectitems) {
            /* later we need to get first activity start dt and last activities end dt in project */
        
    }
    /* 3. Get total cost */
    for (ProjectNSO *project in self.projectitems) {
        /* later we need to get sum of all costs from actitities */
        
    }
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.projectitems.count + 1;;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.projectitems.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.ImageViewProject.image = [UIImage imageNamed:@"AddItem"];
        cell.isNewAccessor = true;
        cell.VisualEffectsViewBlur.hidden = true;
    } else {
        ProjectNSO *project = [self.projectitems objectAtIndex:indexPath.row];
        if (project.Image == nil) {
            cell.ImageViewProject.image = [UIImage imageNamed:@"Project"];
        } else {
            cell.ImageViewProject.image = project.Image;
        }
        cell.LabelProjectName.text = project.name;
        
        cell.isNewAccessor = false;
        if (self.editmode) {
            cell.editButton.hidden=false;
            cell.deleteButton.hidden=false;
            cell.VisualEffectsViewBlur.hidden = false;
        } else {
            cell.editButton.hidden=true;
            cell.deleteButton.hidden=true;
            cell.VisualEffectsViewBlur.hidden = true;
        }
    }
    return cell;
}


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.projectitems.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        /* insert new project item */
        [self performSegueWithIdentifier:@"ShowNewProject" sender:nil];
    } else {
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.db = self.db;
        controller.Project = [self.projectitems objectAtIndex:indexPath.row];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.CollectionViewProjects.frame.size.width;
    float cellWidth = collectionWidth/2.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
    return size;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:            .
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];

}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:            .
 */
- (IBAction)EditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
    
}

- (IBAction)SwitchEditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
}


/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowUpdateProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView = [cellView superview])) {
                if([cellView isKindOfClass:[ProjectListCell class]]) {
                    ProjectListCell *cell = (ProjectListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewProjects indexPathForCell:cell];
                    controller.Project = [self.projectitems objectAtIndex:indexPath.row];
                }
            }
         }
        controller.newitem = false;
        controller.deleteitem = false;

        
    } else if([segue.identifier isEqualToString:@"ShowDeleteProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[ProjectListCell class]]) {
                    ProjectListCell *cell = (ProjectListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewProjects indexPathForCell:cell];
                    controller.Project = [self.projectitems objectAtIndex:indexPath.row];
                }
            }
        }
        controller.newitem = false;
        controller.deleteitem = true;

    } else if([segue.identifier isEqualToString:@"ShowNewProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
        controller.Project = [[ProjectNSO alloc] init];
        controller.newitem = true;
        controller.deleteitem = false;
    }
}



@end
