//
//  ImagePickerVC.m
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:           TODO - send array of images back to the calling viewcontroller.
 */

#import "ImagePickerVC.h"

@interface ImagePickerVC ()

@end

@implementation ImagePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ImageCollectionView.delegate = self;
    self.imageitems = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.LabelPoiName.text = [NSString stringWithFormat:@"Photos nearby %@",self.PointOfInterest.name];
    queueThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector( LoadImageData )
                                                     object:nil ];
    
    [queueThread start ];
}

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:  This runs inside its own thread
 */
-(void) LoadImageData {

    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    
    CLLocationCoordinate2D PoiCoord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    CLLocationCoordinate2D Coord;
   
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    
    CLLocation *PoiLocation = [[CLLocation alloc] initWithLatitude:PoiCoord.latitude longitude:PoiCoord.longitude];
    
    
    
    
    for (PHAsset *item in result) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:item.location.coordinate.latitude longitude:item.location.coordinate.longitude];
        
        double distance = [location distanceFromLocation:PoiLocation];
        
        if (distance< [self.distance doubleValue]) {

            NSLog(@"COORDINATES: %f , %f",Coord.latitude, Coord.longitude);
            NSLog(@"DATE: %@", item.creationDate);
            //__block UIImage *img;
            PHImageManager *manager = [PHImageManager defaultManager];
            //PHImageContentModeDefault
            [manager requestImageForAsset:item targetSize:self.ImageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^void(UIImage *image, NSDictionary *info) {
                if(image){
                    ImageNSO *imageitem = [[ImageNSO alloc] init];
                    imageitem.creationdate = item.creationDate;
                    imageitem.Image = image;
                    imageitem.selected = false;
                    //img = image;
                    [self.imageitems addObject:imageitem];
                    
                }
            }];
            
            if([[NSThread currentThread] isCancelled])
                break;
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found", (unsigned long)self.imageitems.count]];
            });
            
            
        }
        
    }
    NSLog(@"number of results:=%lu", (unsigned long)self.imageitems.count);
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.ButtonStopSearching.hidden = true;
    
        self.LabelWaiting.hidden = true;
        self.ActivityLoading.hidden = true;
        [self.ImageCollectionView reloadData];
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageitems.count;
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageItemCell" forIndexPath:indexPath];
    ImageNSO *img = [self.imageitems objectAtIndex:indexPath.row];
    cell.ViewSelectedBorder.hidden = !img.selected;
    cell.ImageSelected.hidden = !img.selected;
    [cell.Image setImage:img.Image];
    return cell;
}


/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageNSO *img = [self.imageitems objectAtIndex:indexPath.row];
    img.selected = !img.selected;
    NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
    [dtformatter setDateFormat:@"EEE MMM dd YYYY, HH:mm"];
    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"Photo taken %@", [dtformatter stringFromDate:img.creationdate]]];
    [self.ImageCollectionView reloadData];
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.ImageCollectionView.frame.size.width;
    float cellWidth = collectionWidth/4.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
    return size;
}

- (void)didAddImages :(NSMutableArray*)ImageCollection {
    
}

/*
 created date:      11/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (IBAction)AddSelectionPressed:(id)sender {

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = %@", @YES];
    NSMutableArray *imageCollection = [NSMutableArray arrayWithArray:[self.imageitems filteredArrayUsingPredicate:pred]];
    
    [self.delegate didAddImages :imageCollection];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)StopSearchingPressed:(id)sender {
    [queueThread cancel];
    queueThread = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"Image!=NULL"];
    self.imageitems = [NSMutableArray arrayWithArray:[self.imageitems filteredArrayUsingPredicate:pred]];
    
    
    
    self.ButtonStopSearching.hidden = true;
    
    self.LabelWaiting.hidden = true;
    self.ActivityLoading.hidden = true;
    [self.ImageCollectionView reloadData];
    
}

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {

    
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

@end
