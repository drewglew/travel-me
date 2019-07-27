//
//  TravelPlanDetailVC.m
//  trippo
//
//  Created by andrew glew on 21/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "TravelPlanDetailVC.h"

@interface TravelPlanDetailVC ()

@end

@implementation TravelPlanDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ViewPopup.layer.cornerRadius=8.0f;
    self.ViewPopup.layer.masksToBounds=YES;
    self.ViewPopup.layer.borderWidth = 1.0f;
    self.ViewPopup.layer.borderColor = [UIColor blackColor].CGColor;
    [self.ImageViewActivity setImage:self.ActivityImage];
    self.LabelActvityName.text = self.Activity.name;
    
    self.TextFieldDateFrom.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate :self.Activity.startdt]];
    self.TextFieldDateTo.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate :self.Activity.enddt]];
    if (self.Activity.traveltransportid == nil) {
        self.TravelTypeId = [NSNumber numberWithLong:0];
    } else {
        self.TravelTypeId = self.Activity.traveltransportid;
    }
    [self UpdateTravelIcon];
    
    if (self.Activity.travelbackflag == nil || [self.Activity.travelbackflag longValue] == 0) {
        [self.SwitchUseTravelBack setOn:false];
    } else {
        [self.SwitchUseTravelBack setOn:true];
    }
    NSLog(@"%@",self.Activity);
    
    
}

- (IBAction)TransportButtonPressed:(id)sender {
    NSLog(@"you pressed the transport button");
    if (self.TravelTypeId == [NSNumber numberWithLong:0]) {
        self.TravelTypeId = [NSNumber numberWithLong:1];
    } else if (self.TravelTypeId == [NSNumber numberWithLong:1]) {
        self.TravelTypeId = [NSNumber numberWithLong:2];
    } else {
        self.TravelTypeId = [NSNumber numberWithLong:0];
    }
    [self UpdateTravelIcon];
    [self.ButtonUpdate setEnabled:true];
    
}

-(void) UpdateTravelIcon {
    if (self.TravelTypeId == [NSNumber numberWithLong:1]) {
        [self.ButtonTravelType setImage:[UIImage imageNamed:@"transport-walk"] forState:UIControlStateNormal];
    } else if (self.TravelTypeId == [NSNumber numberWithLong:2]) {
        [self.ButtonTravelType setImage:[UIImage imageNamed:@"transport-public"] forState:UIControlStateNormal];
    } else {
        [self.ButtonTravelType setImage:[UIImage imageNamed:@"transport-car"] forState:UIControlStateNormal];
    }
}


- (IBAction)SwitchUseTravelBackChanged:(id)sender {
     [self.ButtonUpdate setEnabled:true];
}


- (IBAction)ButtonUpdatePressed:(id)sender {

    [self.realm beginWriteTransaction];
    
    self.Activity.traveltransportid = self.TravelTypeId;

    if ([self.SwitchUseTravelBack isOn]) {
        self.Activity.travelbackflag = [NSNumber numberWithLong:1];
    } else {
        self.Activity.travelbackflag = [NSNumber numberWithLong:0];
    }
    
    NSLog(@"%@", self.Activity);
    
    [self.realm commitWriteTransaction];
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}




/*
 created date:      21/07/2019
 last modified:     21/07/2019
 remarks:           Usual back button
 */
- (IBAction)BackPressed:(id)sender {
    
     [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
