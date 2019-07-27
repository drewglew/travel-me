//
//  JENNodeView.m
//
//  Created by Jennifer Nordwall on 3/14/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import "JENDefaultNodeView.h"

@interface JENDefaultNodeView ()



@end

@implementation JENDefaultNodeView

@synthesize nodeName = _nodeName;
@synthesize activity = _activity;
@synthesize activityImage = _activityImage;
@synthesize insertNode = _insertNode;
@synthesize nodeSize = _nodeSize;
@synthesize transportType = _transportType;


-(id)initWithParm:(double)NodeSize
{
    self = [super init];
    
    if(self) {
        _nodeSize = NodeSize;
        //_transportType = 0;

        self.activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
        //[self.activityView setBackgroundColor:[UIColor greenColor]];
        [self addSubview:self.activityView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.text = self.nodeName;
        [self.activityView addSubview:self.nameLabel];
        
        self.activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,NodeSize,NodeSize)];
        
        self.activityImageView.layer.cornerRadius = (self.activityImageView.bounds.size.width / 2);
        self.activityImageView.clipsToBounds = YES;
        [self.activityImageView setImage:self.activityImage];
        [self.activityView addSubview:self.activityImageView];
        
        if (NodeSize >= 40.0f) {
            
            self.openOptionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, NodeSize, NodeSize)];
            [self.openOptionsButton addTarget:self action:@selector(OpenOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            [self.activityView addSubview: self.openOptionsButton];
            
            self.activityOptionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
            [self.activityOptionView setBackgroundColor:[UIColor clearColor]];
            [self.activityOptionView setHidden:true];
            [self addSubview:self.activityOptionView];
            
            UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            moreButton.frame = CGRectMake(0.0, 0.0, NodeSize/3, NodeSize/3);
            [moreButton addTarget:self action:@selector(MoreButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            //UIImage *image = [[UIImage imageNamed:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [moreButton setImage:[[UIImage imageNamed:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            moreButton.tintColor = [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: moreButton];
            
            UIButton *closeOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeOptionButton.frame = CGRectMake(NodeSize - (NodeSize/3), NodeSize - (NodeSize/3), NodeSize/3, NodeSize/3);
            [closeOptionButton addTarget:self action:@selector(CloseOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            //UIImage *image = [[UIImage imageNamed:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [closeOptionButton setImage:[[UIImage imageNamed:@"Close-View"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            closeOptionButton.tintColor = [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: closeOptionButton];
            
            UIButton *newOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            newOptionButton.frame = CGRectMake(0, NodeSize - (NodeSize/3), NodeSize/3, NodeSize/3);
            [newOptionButton addTarget:self action:@selector(NewOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            //UIImage *image = [[UIImage imageNamed:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [newOptionButton setImage:[[UIImage imageNamed:@"MenuAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            newOptionButton.tintColor =  [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: newOptionButton];
            
            self.transportImageView = [[UIImageView alloc] initWithFrame:CGRectMake(NodeSize - (NodeSize/3), 0, NodeSize/3, NodeSize/3)];
            [self.activityOptionView addSubview: self.transportImageView];
            
            double TravelBackIndicatorSize = 30.0f;
            //if (NodeSize/3 < 30.0f) {
                TravelBackIndicatorSize = NodeSize / 6.0f;
            //}
            self.transportTravelBackIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(-TravelBackIndicatorSize/2, (NodeSize/2) - (TravelBackIndicatorSize/2) , TravelBackIndicatorSize, TravelBackIndicatorSize)];
            [self.transportTravelBackIndicator setImage:[UIImage imageNamed:@"TravelBackIndicator"]];
            [self.activityOptionView addSubview: self.transportTravelBackIndicator];
            [self.transportTravelBackIndicator setHidden:false];
 
        }
    }
    return self;
}
    

-(void)setTransportType:(NSNumber*)transportType {
    
        _transportType = transportType;
        if (transportType == [NSNumber numberWithLong:1]) {
            [self.transportImageView setImage:[UIImage imageNamed:@"transport-walk"]];
        } else if (transportType == [NSNumber numberWithLong:2]) {
            [self.transportImageView setImage:[UIImage imageNamed:@"transport-public"]];
        } else {
            [self.transportImageView setImage:[UIImage imageNamed:@"transport-car"]];
        }
    
}


-(void)setTravelBack:(NSNumber *)travelBack {
_travelBack = travelBack;
    if (travelBack == [NSNumber numberWithLong:0] || travelBack == nil) {
        [self.transportTravelBackIndicator setHidden:true];
    } else {
        [self.transportTravelBackIndicator setHidden:false];
    }
}

// not used..
-(void)setInsertNode:(bool)insertNode {
     if(insertNode != _insertNode) {
         insertNode = _insertNode;
     }
}

-(void)setNodeName:(NSString *)nodeName {
    if(nodeName != _nodeName) {
        _nodeName = nodeName;
        self.nameLabel.text = nodeName;
        
        if ([nodeName isEqualToString:@"Trip"]) {
            self.openOptionsButton.enabled = false;
        }
        
        double sizeOfNode = _nodeSize;
        if (sizeOfNode == 0.0f) {
            sizeOfNode = 75.0f;
        }
 
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                sizeOfNode,
                                sizeOfNode);

        self.nameLabel.frame = CGRectMake(self.bounds.origin.x + 5,
                                          self.bounds.origin.y + 5,
                                          self.bounds.size.width - 10,
                                          self.bounds.size.height - 10);
    }
}


-(void)setNodeSize:(double)nodeSize {
    if(nodeSize != _nodeSize) {
        _nodeSize = nodeSize;
    }
}

// called 7 times
-(void)setActivityImage:(UIImage *)activityImage {
    if(activityImage != _activityImage) {
        _activityImage = activityImage;
        [_activityImageView setImage:activityImage];
    }
}

// called 7 times??
-(void)setActivity:(ActivityRLM *)activity {
    if(activity != _activity) {
        _activity = activity;
    }
}




- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
 
         
-(void) CloseOptionButtonPressed {
    NSLog(@"you pressed the close option button");
    if (self.activityOptionView!=nil) {
        [self.activityOptionView setHidden: true];
    }
}

-(void) MoreButtonPressed {
    NSLog(@"you pressed the more button");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TravelPlanDetailVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"TravelPlanDetailViewController"];
    controller.delegate = self;
    controller.Activity = self.activity;
    controller.ActivityImage = self.activityImage;
    [controller setModalPresentationStyle:UIModalPresentationOverFullScreen];
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    controller.realm = currentTopVC.realm;
    [currentTopVC presentViewController:controller animated:YES completion:nil];
}

-(void) NewOptionButtonPressed {
    NSLog(@"you pressed the new option button");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
    controller.delegate = self;
    controller.Activity = [[ActivityRLM alloc] init];

    controller.transformed = false;
    [controller setModalPresentationStyle:UIModalPresentationOverFullScreen];
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    controller.realm = currentTopVC.realm;
    [currentTopVC presentViewController:controller animated:YES completion:nil];
    controller.TripItem = currentTopVC.Trip;
    controller.Activity.state = self.activity.state;
    controller.Activity.startdt = self.activity.startdt;
    controller.Activity.enddt = self.activity.enddt;
    controller.newitem = true;
}


-(void) OpenOptionButtonPressed{
    NSLog(@"you pressed the open option button");
    if (self.activityOptionView!=nil) {
        [self.activityOptionView setHidden: false];
    }
}


- (void)didCreatePoiFromProject:(PoiNSO *)Object {
}

- (void)didUpdatePoi:(NSString *)Method :(PoiNSO *)Object {
}

- (void)didUpdateActivityImages :(bool) ForceUpdate {
}


@end
