//
//  MenuVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC () <PoiListDelegate>

@end

@implementation MenuVC

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
*/
-(void)CreateDB {
    [self.db Create :@"travelme_01.db"];
}
/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
-(void)DeleteDB {
    [self.db Delete:@"travelme_01.db"];
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.db = [[Dal alloc] init];
    
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           temporary button pressed to create db.
 */
- (IBAction)CreateDatabasePressed:(id)sender {
    
    [self CreateDB];
    
}


/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowPoiList"]){
        PoiListVC *controller = (PoiListVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.db = self.db;
    }
}


/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:           temporary button pressed to delete db.
 */
- (IBAction)DeleteDatabasePressed:(id)sender {
    
    [self DeleteDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
