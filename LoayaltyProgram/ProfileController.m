//
//  Profile.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "ProfileController.h"
#import "Firebase.h"
#import "User.h"
#import "GuestCardController.h"
#import "EditProfileController.h"

@interface ProfileController ()

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userPointsLabel;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UIImageView *topImage;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) User *user;


@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    [self setupImageView];
    self.user = [[User alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkIfUserIsLoggedIn];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserves];
}

- (void)removeObserves {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    if (userID != nil) {
        [[[self.reference child:@"users"] child:userID] removeAllObservers];
    }
}

- (void)checkIfUserIsLoggedIn {
    if ([[FIRAuth auth] currentUser].uid == nil){
        [self handleSignout:nil];
    } else{
        [self getUser];
    }
}

- (void)setupImageView{
    self.userImageView.layer.cornerRadius = self.userImageView.layer.frame.size.width/2;
    self.userImageView.layer.masksToBounds = YES;
}

- (void)getUser {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[self.reference child:@"users"] child:userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {

        self.user.name = snapshot.value[@"username"];
        self.user.gender = snapshot.value[@"gender"];
        self.user.birthday = snapshot.value[@"birtday"];
        self.user.phoneNumber = snapshot.value[@"phoneNumber"];
        self.user.email = snapshot.value[@"email"];
        self.user.profileImageURL = snapshot.value[@"profileImageURL"];
        self.user.points = [snapshot.value[@"points"] intValue];
        self.user.uid = userID;
        
        self.navigationItem.title = self.user.name;
        self.userPointsLabel.text = [NSString stringWithFormat:@"%d",self.user.points];
        
        NSURL *url = [NSURL URLWithString:self.user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showAlertWithError:error];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImageView.image = [UIImage imageWithData:data];
            });
            if (self.user.profileImageData != data) {
                self.user.profileImageData = data;
            }
        }] resume];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showAlertWithError:error];
            return;
        }
    }];
}

- (IBAction)handleSignout:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        if (signOutError){
            [self showAlertWithError:signOutError];
            return;
        }
        return;
    }
    [self performSegueWithIdentifier:@"profileToLogin" sender:self];
}

- (void)showAlertWithError:(NSError*)error {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:[error.userInfo objectForKey:@"error_name"]
                                 message:[error.userInfo objectForKey:@"NSLocalizedDescription"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"profileToGuestcard"]) {
        GuestCardController *upcoming = segue.destinationViewController;
        upcoming.user = self.user;
    }else if ([[segue identifier] isEqualToString:@"profileToEdit"]) {
        UINavigationController *nav = [segue destinationViewController];
        EditProfileController *editProfileController = (EditProfileController *)nav.topViewController;
        editProfileController.user = self.user;
    }
}

@end
