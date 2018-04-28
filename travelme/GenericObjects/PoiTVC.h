//
//  PoiTVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiNSO.h"

@interface PoiTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Country;
@property (strong, nonatomic) PoiNSO *poi;

@end
