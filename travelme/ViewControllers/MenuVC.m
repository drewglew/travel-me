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
    
    [self.ButtonPoi.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.ButtonProject.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           temporary button pressed to create db.
 */
- (IBAction)CreateDatabasePressed:(id)sender {
    [self CreateDb];
}


/*
 created date:      27/04/2018
 last modified:     29/04/2018
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
    } else  if([segue.identifier isEqualToString:@"ShowProjectList"]){
        ProjectListVC *controller = (ProjectListVC *)segue.destinationViewController;
        controller.delegate = self;
    }
}


/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           temporary button pressed to delete db.
 */
- (IBAction)DeleteDatabasePressed:(id)sender {
    
    [self DeleteDb];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
