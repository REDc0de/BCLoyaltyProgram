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

@interface ProfileController ()
@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userPointsLabel;

@property (strong, nonatomic) User *user;

@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    [self setupImageView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkIfUserIsLoggedIn];
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
        
        User *user = [[User alloc] initWithUserName:snapshot.value[@"username"]
                                              email:snapshot.value[@"email"]
                                    profileImageURL:snapshot.value[@"profileImageURL"]
                                             points:[snapshot.value[@"points"] intValue]
                                                uid:userID];
        
        self.navigationItem.title = user.name;
        self.userPointsLabel.text = [NSString stringWithFormat:@"%d",user.points];
        self.user = user;
        
        
        NSURL *url = [NSURL URLWithString:user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error){
                [self showAlertWithError:error];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
        
        
        //
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
        //if you need to pass data to the next controller do it here
        GuestCardController *upcoming = segue.destinationViewController;
       
        upcoming.user = self.user;
    }
}

@end
