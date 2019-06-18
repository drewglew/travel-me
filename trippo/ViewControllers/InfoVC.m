//
//  InfoVC.m
//  travelme
//
//  Created by andrew glew on 13/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "InfoVC.h"

@interface InfoVC ()

@end

@implementation InfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.LabelVersion.text = [NSString stringWithFormat: @"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    
    
    
    
    
    
    
    
    
   
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
