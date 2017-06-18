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
#import "UIViewController+Alerts.h"
#import <QuartzCore/QuartzCore.h>


@interface ProfileController ()

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (strong, nonatomic) UIImageView *topImage;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *guestCardButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userPointsButton;

@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    [self setupImageView];
    [self setupGuestCardButton];
    self.user = [[User alloc] init];
    
    
    
    self.userPointsButton.backgroundColor = [UIColor colorWithRed:219.0/255 green:16.0/255 blue:32.0/255 alpha:1.0];
    self.userPointsButton.layer.cornerRadius = 24.0;
    self.userPointsButton.tintColor = [UIColor whiteColor];
    
    self.userPointsButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.userPointsButton.layer.shadowRadius = 4.0;
    self.userPointsButton.layer.shadowOpacity = 0.8;
    self.userPointsButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [self handleSignout:nil];
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

- (void)setupGuestCardButton {
    self.guestCardButton.layer.cornerRadius = 4;
    self.guestCardButton.layer.masksToBounds =YES;
}

- (void)getUser {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[self.reference child:@"users"] child:userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (!snapshot.hasChildren) {
            [self handleSignout:nil];
            return;
        }

        self.user.name = snapshot.value[@"username"];
        self.user.gender = snapshot.value[@"gender"];
        self.user.birthday = snapshot.value[@"birtday"];
        self.user.phoneNumber = snapshot.value[@"phoneNumber"];
        self.user.email = snapshot.value[@"email"];
        self.user.profileImageURL = snapshot.value[@"profileImageURL"];
        self.user.points = [snapshot.value[@"points"] intValue];
        self.user.uid = userID;
        
//        self.navigationItem.title = self.user.name;
        self.userNameLabel.text = self.user.name;
//        self.userPointsButton.titleLabel.text = [NSString stringWithFormat:@" ★%d ",self.user.points];
//        
        
        
        [self.userPointsButton setTitle:[NSString stringWithFormat:@" ★%d ",self.user.points] forState:UIControlStateNormal];
        [self.userPointsButton setNeedsLayout];
        [self.userPointsButton layoutIfNeeded];
        
        NSURL *url = [NSURL URLWithString:self.user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImageView.image = [UIImage imageWithData:data];
                
//                //Add Image and Text to Navigation Title
//                UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 30)];
//                UILabel *title = [[UILabel alloc] initWithFrame: CGRectMake(40, 0, 300, 30)];
//                
//                title.text = NSLocalizedString(self.user.name, nil);
//                [title setTextColor:[UIColor blackColor]];
//                [title setFont:[UIFont boldSystemFontOfSize:20.0]];
//                
//                [title setBackgroundColor:[UIColor clearColor]];
//                UIImage *image = [UIImage imageWithData:data];
//                UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
//                
//                myImageView.frame = CGRectMake(0, 0, 30, 30);
//                myImageView.layer.cornerRadius = 15.0;
//                myImageView.layer.masksToBounds = YES;
//                myImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//                myImageView.layer.borderWidth = 0.1;
//                
//                [myView addSubview:title];
//                [myView setBackgroundColor:[UIColor  clearColor]];
//                [myView addSubview:myImageView];
//                self.navigationItem.titleView = myView;
                
            });
            if (self.user.profileImageData != data) {
                self.user.profileImageData = data;
            }
        }] resume];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
    }];
}

- (IBAction)handleSignout:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        if (signOutError){
            [self showMessagePrompt: signOutError.localizedDescription];
            return;
        }
        return;
    }
    [self performSegueWithIdentifier:@"profileToLogin" sender:self];
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
