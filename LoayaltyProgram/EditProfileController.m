//
//  EditProfileController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 16.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "EditProfileController.h"
#import "Firebase.h"

@interface EditProfileController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation EditProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.clearsSelectionOnViewWillAppear = YES;
    [self imageViewSetup];
    self.nameTextField.text = self.user.name;
    self.genderTextField.text = self.user.gender;
    self.birthdayTextField.text = self.user.birthday;
    self.phoneTextField.text = self.user.phoneNumber;
    self.emailTextField.text = self.user.email;
}

- (void)imageViewSetup {
    if (self.user.profileImageData){
        self.profileImageView.image = [UIImage imageWithData:self.user.profileImageData];
    } else{
        NSURL *url = [NSURL URLWithString:self.user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error){
                [self showAlertWithError:error];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
}


- (IBAction)handleCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleDone:(id)sender {
//    NSString *key = [[self.ref child:@"users"] child:self.user.uid].key;
//    NSDictionary *post = @{@"username": self.user.name,
//                             @"gender": self.user.gender,
//                            @"birtday": self.user.birthday,
//                        @"phoneNumber": self.user.phoneNumber,
//                              @"email": self.user.email,
//                             @"points": [NSString stringWithFormat:@"%d", self.user.points],
//                    @"profileImageURL": self.user.profileImageURL};
//    NSDictionary *childUpdates = @{[@"/users/" stringByAppendingString:key]: post,
//                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", self.user.uid, key]: post};
//    [_ref updateChildValues:childUpdates];
}

- (IBAction)handleDeleteProfile:(id)sender {
    FIRUser *user = [FIRAuth auth].currentUser;
    
    [[[self.ref child:@"users"] child:user.uid] removeValue];
    // Account from realtime database deleted.
    
    [user deleteWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            // An error happened.
            [self showAlertWithError:error];
        } else {
            // Account deleted.
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
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

@end
