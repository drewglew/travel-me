//
//  SettingsVC.m
//  travelme
//
//  Created by andrew glew on 23/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "SettingsVC.h"
#import <TwitterKit/TWTRLogInButton.h>
@interface SettingsVC ()

@end

@implementation SettingsVC

/*
 created date:      23/08/2018
 last modified:     16/03/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.TextFieldNickName.delegate = self;
    self.TextFieldEmail.delegate = self;
    
    if (self.Settings!=nil) {
        self.TextFieldNickName.text = self.Settings.username;
        self.TextFieldEmail.text = self.Settings.useremail;
    }
    
    self.ViewUserName.layer.cornerRadius = 5;
    self.ViewUserName.layer.masksToBounds = true;
    self.ViewEmailInfo.layer.cornerRadius = 5;
    self.ViewEmailInfo.layer.masksToBounds = true;
    
    self.TextFieldNickName.layer.borderWidth = 1.0f;
    self.TextFieldNickName.layer.borderColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0].CGColor;
    
    self.TextFieldEmail.layer.borderWidth = 1.0f;
    self.TextFieldEmail.layer.borderColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0].CGColor;
    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            
            
            NSLog(@"Logged in as %@",[session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    //CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    
    logInButton.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2 - 20, logInButton.bounds.size.height);

    [self.ViewTwitterLogIn addSubview:logInButton];
    
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

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}


/*
 created date:      19/02/2019
 last modified:     19/02/2019
 remarks:
 */
- (IBAction)ActionButtonPressed:(id)sender {
    
    if ([self.TextFieldEmail.text isEqualToString:@""] && [self.TextFieldNickName.text isEqualToString:@""]) {
    
    } else {
        if (self.Settings == nil) {
            self.Settings = [[SettingsRLM alloc] init];
            self.Settings.userkey = [[NSUUID UUID] UUIDString];
            self.Settings.username = self.TextFieldNickName.text;
            self.Settings.useremail = self.TextFieldEmail.text;
            
            [self.realm beginWriteTransaction];
            [self.realm addObject:self.Settings];
            [self.realm commitWriteTransaction];
            
        } else {
            [self.Settings.realm beginWriteTransaction];
            self.Settings.username = self.TextFieldNickName.text;
            self.Settings.useremail = self.TextFieldEmail.text;
            [self.Settings.realm commitWriteTransaction];
        }
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    
}



@end
