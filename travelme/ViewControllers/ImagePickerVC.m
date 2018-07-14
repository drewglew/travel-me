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
    if (!self.wikiimages) {
        self.LabelPoiName.text = [NSString stringWithFormat:@"Photos nearby %@",self.PointOfInterest.name];
    } else {
        self.LabelPoiName.text = [NSString stringWithFormat:@"Web Photos of %@",self.PointOfInterest.name];
    }
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    queueThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector( LoadImageData )
                                                     object:nil ];
    
    [queueThread start ];
}

/*
 created date:      10/06/2018
 last modified:     14/07/2018
 remarks:  This runs inside its own thread - one of the most complex methods in the application.
 */
-(void) LoadImageData {


    if (!self.wikiimages) {
        CLLocationCoordinate2D PoiCoord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        CLLocationCoordinate2D Coord;
        
        CLLocation *PoiLocation = [[CLLocation alloc] initWithLatitude:PoiCoord.latitude longitude:PoiCoord.longitude];
        int MaxNumberOfPhotos = 200;
        int PhotoCounter = 0;
        
        
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
        
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];

        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode   = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;

        for (PHAsset *item in result) {
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:item.location.coordinate.latitude longitude:item.location.coordinate.longitude];
            
            double distance = [location distanceFromLocation:PoiLocation];
            
            if (distance < [self.distance doubleValue]) {

                if (PhotoCounter < MaxNumberOfPhotos) {
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
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                 [self.ImageCollectionView reloadData];
                            });
                            
                        }
                    }];
                    PhotoCounter++;
                }
                
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
            
            self.ActivityLoading.hidden = true;
            [self.ImageCollectionView reloadData];
        });
    } else {
            /*
             Obtain Wiki data based on name.
             https://en.wikipedia.org/api/rest_v1/page/media/Göteborg
             */
            NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];
            NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/media/%@",[parms objectAtIndex:0] , [parms objectAtIndex:1]];
            
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [self fetchFromWikiApiMediaByTitle:url withDictionary:^(NSDictionary *data) {

                NSDictionary *items = [data objectForKey:@"items"];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"Checking %lu Web Assets", (unsigned long)items.count]];
                });
                __block int AssetCounter = 0;
                
                /* we can process all later, but am only interested in the closest wiki entry */
                for (NSDictionary *item in items) {
                    int MaxNumberOfPhotos = 200;

                    NSDictionary *DescriptionItem = [item objectForKey:@"description"];
                    
                    /* no more than 200 photos! */
                    if (self.imageitems.count < MaxNumberOfPhotos) {
                    
                        NSDictionary *OriginalItem = [item objectForKey:@"original"];
                       

                        /* check type & size of original photo asset if it is larger than 3000x3000 or it is of svg type we use the thumbnail image instead */
                        if ([[OriginalItem valueForKey:@"mime"] isEqualToString:@"image/svg+xml"] || ([[OriginalItem valueForKey:@"width"] longValue] > 3000 || [[OriginalItem valueForKey:@"height"] longValue] > 3000) ) {
                            
                            NSDictionary *ThumbnailItem = [item objectForKey:@"thumbnail"];
                            
                            [self downloadImageFrom:[NSURL URLWithString:[ThumbnailItem valueForKey:@"source"]] completion:^(UIImage *image) {

                                AssetCounter ++;
                                
                                
                                if (image!=nil) {
                                    ImageNSO *imageitem = [[ImageNSO alloc] init];
                                    if (image.size.height > image.size.width) {
                                        CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                    } else if (image.size.height < image.size.width) {
                                        CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                    }
                                    imageitem.Image = [ToolBoxNSO imageWithImage:image scaledToSize:self.ImageSize];
                                    if (DescriptionItem.count>0) {
                                        imageitem.WikiDescription = [DescriptionItem objectForKey:@"text"];
                                    }
                                    imageitem.selected = false;
                                    [self.imageitems addObject:imageitem];
                                    // keep the collection view updated with the new image
                                    [self.ImageCollectionView reloadData];
                                    
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^(){
                                    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found inside %lu Web Assets", (unsigned long)self.imageitems.count,(unsigned long)items.count]];
                                     if (AssetCounter==items.count) {
                                         self.ButtonStopSearching.hidden = true;
                                         
                                         self.ActivityLoading.hidden = true;
                                     }
                                 });

                            }];
                        
                        /* ok if mine type is an image we can handle load it in */
                        } else if ([[OriginalItem valueForKey:@"mime"] isEqualToString:@"image/jpeg"] || [[OriginalItem valueForKey:@"mime"] isEqualToString:@"image/png"]) {

                            [self downloadImageFrom:[NSURL URLWithString:[OriginalItem valueForKey:@"source"]] completion:^(UIImage *image) {
                                AssetCounter ++;
                                if (image!=nil) {
                                    ImageNSO *imageitem = [[ImageNSO alloc] init];
                                    
                                    if (image.size.height > image.size.width) {
                                        CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                    } else if (image.size.height < image.size.width) {
                                        CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                    }
                                    
                                    imageitem.Image = [ToolBoxNSO imageWithImage:image scaledToSize:self.ImageSize];
                                    if (DescriptionItem.count>0) {
                                        imageitem.WikiDescription = [DescriptionItem objectForKey:@"text"];
                                    } else {
                                        imageitem.WikiDescription = @"No description available";
                                    }
                                    imageitem.selected = false;
                                    [self.imageitems addObject:imageitem];
                                     // keep the collection view updated with the new image
                                    [self.ImageCollectionView reloadData];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^(){
                                    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found inside %lu Web Assets", (unsigned long)self.imageitems.count,(unsigned long)items.count]];
                                    
                                    if (AssetCounter==items.count) {
                                        self.ButtonStopSearching.hidden = true;
                                        self.ActivityLoading.hidden = true;
                                    }
                                });

                            }];
                        } else {
                            AssetCounter ++;
                            if (AssetCounter==items.count) {
                                self.ButtonStopSearching.hidden = true;
                                self.ActivityLoading.hidden = true;
                            }
                        }
                    }
                    
                    if([[NSThread currentThread] isCancelled])
                        break;
                }
            }];
    }
}

/*
 created date:      14/07/2018
 last modified:     14/07/2018
 remarks:
 */
- (void)downloadImageFrom:(NSURL *)path completion:(void (^)(UIImage *image))completionBlock {
    dispatch_queue_t queue = dispatch_queue_create("Image Download", 0);
    dispatch_async(queue, ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data) {
                completionBlock([[UIImage alloc] initWithData:data]);
            } else {
                completionBlock(nil);
            }
        });
    });
}


/*
 created date:      14/07/2018
 last modified:     14/07/2018
 remarks:
 */
-(void)fetchFromWikiApiMediaByTitle:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
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
    
    if (!self.wikiimages) {
        NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
        [dtformatter setDateFormat:@"EEE MMM dd YYYY, HH:mm"];
        [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"Photo taken %@", [dtformatter stringFromDate:img.creationdate]]];
    } else {
        [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%@", img.WikiDescription]];
    }
    
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
 last modified:     14/07/2018
 remarks:
 */
- (IBAction)AddSelectionPressed:(id)sender {

    [queueThread cancel];
    queueThread = nil;
    
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

    self.ActivityLoading.hidden = true;
    [self.ImageCollectionView reloadData];
    
}

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [queueThread cancel];
    queueThread = nil;
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

@end
