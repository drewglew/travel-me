//
//  PoiTVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiNSO.h"

@interface PoiListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *AdministrativeArea;
@property (weak, nonatomic) IBOutlet UIImageView *PoiKeyImage;


@property (strong, nonatomic) PoiNSO *poi;
@property (weak, nonatomic) IBOutlet UIImageView *ImageCategory;

@end
