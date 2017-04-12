//
//  Login.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 09.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "LoginController.h"
#import "Firebase.h"

@interface LoginController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRegisterButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) FIRDatabaseReference *reference;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    [self textFieldSetup];
    [self buttonSetup];
    [self imageViewSetup];
    [self handleLoginRegisterChange];
}

- (void)textFieldSetup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)buttonSetup {
    self.loginRegisterButton.layer.cornerRadius = 4.0;
}

- (void)imageViewSetup {
    self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectProfileImageView)];
    [self.profileImageView addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)handleSelectProfileImageView {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImageFromPicker;
    if ([info valueForKey:UIImagePickerControllerEditedImage]){
        selectedImageFromPicker = [info valueForKey:UIImagePickerControllerEditedImage];
    } else{
        selectedImageFromPicker = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    
    if(selectedImageFromPicker) {
        self.profileImageView.image = selectedImageFromPicker;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleLoginRegister:(id)sender {
    [self dismissKeyboard];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self handleLogin];
            break;
        case 1:
            [self handleRegister];
            break;
    }
}

- (IBAction)handleSegmentedControl:(id)sender {
    [self dismissKeyboard];
    [self handleLoginRegisterChange];
}

- (void)handleLoginRegisterChange {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self updateUIForLoggin];
            break;
        case 1:
            [self updateUIForRegistration];
            break;
    }
}

- (void)updateUIForLoggin {
    self.nameTextField.hidden = YES;
    self.profileImageView.userInteractionEnabled = NO;
    self.profileImageView.image = [UIImage imageNamed:@"Logo.png"];
    [self.loginRegisterButton setTitle:@"Login" forState:UIControlStateNormal];
}

- (void)updateUIForRegistration {
    self.nameTextField.hidden = NO;
    self.profileImageView.userInteractionEnabled = YES;
    self.profileImageView.image = [UIImage imageNamed:@"AddProfileImage.png"];
    [self.loginRegisterButton setTitle:@"Registration" forState:UIControlStateNormal];
}

- (void)handleLogin{
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                           
                             if (error){
                                 [self showAlertWithError:error];
                                 return;
                             }
                             [self dismissViewControllerAnimated:YES completion:nil];
                             NSLog(@"We successfully login user.");
                         }];
}

- (void)handleRegister {
    NSString *name = self.nameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    UIImage *profileImage = self.profileImageView.image;
    
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 
                                 if (error){
                                     [self showAlertWithError:error];
                                     return;
                                 }
                                
                                 NSString *uid = user.uid;
                                 NSString *imageName = [[NSUUID UUID] UUIDString];
                                 
                                 FIRStorage *storage = [FIRStorage storage];
                                 FIRStorageReference *storageRef = [storage reference];
                                 FIRStorageReference *profileRef = [storageRef child:[NSString stringWithFormat:@"users/profile_images/%@.jpg",imageName]];
                                 
                                 NSData *uploadImage = UIImageJPEGRepresentation(profileImage, 0.1);

                                 [profileRef putData:uploadImage
                                            metadata:nil
                                          completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                              if (error != nil) {
                                                  [self showAlertWithError:error];
                                                  return;
                                              } else {
                                                  NSString *profileImageURL = [NSString stringWithFormat:@"%@", metadata.downloadURL];
                                    
                                                  NSDictionary *values = @{@"username": name,
                                                                              @"email": email,
                                                                             @"points": @0,
                                                                    @"profileImageURL": profileImageURL};
                                                  [self registerUserIntoDatabaseWithUID:uid values:values];
                                              }
                                   }];
                             }];
}

- (void)registerUserIntoDatabaseWithUID:(NSString*)uid values:(NSDictionary*)values {
    [[[self.reference child:@"users"] child:uid] setValue:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error){
            [self showAlertWithError:error];
            return;
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"We successfully register new user.");
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
