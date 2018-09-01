//
//  SettingsVC.m
//  travelme
//
//  Created by andrew glew on 23/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)UpdateSharedAlbumButtonPressed:(id)sender {
    
    __block PHFetchResult *photosAsset;
    __block PHAssetCollection *collection;
    __block PHObjectPlaceholder *placeholder;
    
    // Find the album
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"YOUR_ALBUM_TITLE"];
    collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                          subtype:PHAssetCollectionSubtypeAny
                                                          options:fetchOptions].firstObject;
    // Create the album
    if (!collection)
    {
        
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"YOUR_ALBUM_TITLE"];
            placeholder = [createAlbum placeholderForCreatedAssetCollection];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                            options:nil];
                collection = collectionFetchResult.firstObject;
            }
        }];
    }
    
    
    UIImage *testImage = [UIImage imageNamed:@"Poi"];
    
    // Save to the album
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:testImage];
        placeholder = [assetRequest placeholderForCreatedAsset];
        photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection
                                                                                                                      assets:photosAsset];
        [albumChangeRequest addAssets:@[placeholder]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
            NSString *UUID = [placeholder.localIdentifier substringToIndex:36];
            
            
           
           // photo.assetURL = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
            //[self savePhoto];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
    
    
}

- (IBAction)BackButtonPressed:(id)sender {
     [self dismissViewControllerAnimated:YES completion:Nil];
    
}

- (IBAction)LogoutButton:(id)sender {
    
    NSDictionary<NSString *, RLMSyncUser *> *allUsers = [RLMSyncUser allUsers];

    if (allUsers.count==1) {
        RLMSyncUser *user = [RLMSyncUser currentUser];
        [user logOut];
    }
    
    
    
}

@end
