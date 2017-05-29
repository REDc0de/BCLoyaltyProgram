//
//  EditProfileController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 16.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "EditProfileController.h"
#import "Firebase.h"
#import "UIViewController+Alerts.h"


@interface EditProfileController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSArray *genderPickerData;
@property (strong, nonatomic) FIRUser *currentFIRUser;
@property (strong, nonatomic) NSMutableDictionary *mutableValuesDictionary;

@end

@implementation EditProfileController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.mutableValuesDictionary = [[NSMutableDictionary alloc] init];
    
    self.passwordTextField.text = @"11111";
    self.repeatPasswordTextField.text = @"11111";
    
    self.currentFIRUser = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] reference];
    self.clearsSelectionOnViewWillAppear = YES;
    self.nameTextField.text = self.user.name;
    self.genderTextField.text = self.user.gender;
    self.birthdayTextField.text = self.user.birthday;
    self.phoneTextField.text = self.user.phoneNumber;
    self.emailTextField.text = self.user.email;
    
    [self textFieldSetup];
    [self imageViewSetup];
    [self genderPickerViewSetup];
    [self datePickerSetup];
}

#pragma mark - Date Picker

- (void)datePickerSetup {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:0];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-256];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMinimumDate:minDate];
    [datePicker setMaximumDate:maxDate];
    

//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd MMM',' YYYY"];
//    NSDate *date = [dateFormatter dateFromString:self.birthdayTextField.text];
//    
    [datePicker setDate:[NSDate date]];
    
   // NSLog(@"%@, %@", self.birthdayTextField.text, date);
    [datePicker addTarget:self action:@selector(updateBirthdayTextField:) forControlEvents:UIControlEventValueChanged];
    
    [self.birthdayTextField setInputView:datePicker];
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0,0, self.view.frame.size.width, 44)];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(handleDatePickerDoneAction)];
    
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.birthdayTextField.inputAccessoryView = myToolbar;
}

- (void)handleDatePickerDoneAction{
    [self updateBirthdayTextField:nil];
    [self dismissKeyboard];
}

- (void)updateBirthdayTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.birthdayTextField.inputView;
    self.birthdayTextField.text = [self formatDate:picker.date];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd MMM, YYYY"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}


#pragma mark - Gender Picker

- (void)genderPickerViewSetup {
    self.genderPickerData = @[@"",@"male",@"female"];
    
    UIPickerView *yourpicker = [[UIPickerView alloc] init];
    [yourpicker setDataSource: self];
    [yourpicker setDelegate: self];
    yourpicker.showsSelectionIndicator = YES;
    self.genderTextField.inputView = yourpicker;
    
    UIToolbar *genderPickerToolbar = [[UIToolbar alloc] initWithFrame:
                                      CGRectMake(0,0, self.view.frame.size.width, 44)]; //should code with variables to support view resizing
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(dismissKeyboard)];
    [genderPickerToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.genderTextField.inputAccessoryView = genderPickerToolbar;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.genderPickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.genderPickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.genderTextField.text = self.genderPickerData[row];
}


#pragma mark - TextField

- (void)textFieldSetup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.nameTextField.delegate = self;
    self.birthdayTextField.delegate = self;
    self.genderTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.repeatPasswordTextField.delegate = self;
}

- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.birthdayTextField resignFirstResponder];
    [self.genderTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.repeatPasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - ImagePickerController

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


- (void)imageViewSetup {
    if (self.user.profileImageData){
        self.profileImageView.image = [UIImage imageWithData:self.user.profileImageData];
    } else{
        NSURL *url = [NSURL URLWithString:self.user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectProfileImageView)];
    [self.profileImageView addGestureRecognizer:tap];
}

- (IBAction)handleCancel:(id)sender {
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleDone:(id)sender {
    [self dismissKeyboard];
    [self updateProfile];
}

- (void)updateProfile {
    UIImage *profileImage = self.profileImageView.image;
    NSData *uploadImage = UIImageJPEGRepresentation(profileImage, 0.1);
    [self showSpinner:^{
        if (self.user.profileImageData != uploadImage) {
            // Upload profile image.
            NSString *imageName = [[NSUUID UUID] UUIDString];
            FIRStorage *storage = [FIRStorage storage];
            FIRStorageReference *storageRef = [storage reference];
            FIRStorageReference *profileRef = [storageRef child:[NSString stringWithFormat:@"users/profile_images/%@.jpg",imageName]];
            NSData *uploadImage = UIImageJPEGRepresentation(profileImage, 0.1);
            
            [profileRef putData:uploadImage
                       metadata:nil
                     completion:^(FIRStorageMetadata *metadata, NSError *error) {
                         if (error) {
                             [self hideSpinner:^{
                                 [self showMessagePrompt: error.localizedDescription];
                             }];
                             return;
                         } else {
                             NSString *profileImageURL = [NSString stringWithFormat:@"%@", metadata.downloadURL];
                             [self.mutableValuesDictionary setObject:profileImageURL forKey:@"profileImageURL" ];
                             // Select fields for update.
                             [self selectFieldsForUpdate];
                         }
                     }];
        } else {
            // Select fields for update.
            [self selectFieldsForUpdate];
        }
    }];
}

- (void)selectFieldsForUpdate {
    if (self.user.name !=self.nameTextField.text) {
        [self.mutableValuesDictionary setObject:self.nameTextField.text forKey:@"username" ];
    }
    if (self.user.gender !=self.genderTextField.text) {
        [self.mutableValuesDictionary setObject:self.genderTextField.text forKey:@"gender"];
    }
    if (self.user.birthday !=self.birthdayTextField.text) {
        [self.mutableValuesDictionary setObject:self.birthdayTextField.text forKey:@"birtday"];
    }
    if (self.user.phoneNumber !=self.phoneTextField.text) {
        [self.mutableValuesDictionary setObject:self.phoneTextField.text forKey:@"phoneNumber"];
    }

    if ( [self.currentFIRUser.email isEqualToString:self.emailTextField.text] && [self.passwordTextField.text  isEqual: @"11111"]){
        [self updateUserProfileValues];
    } else {
        [self hideSpinner:^{
            // re-Authenticate user.
            [self showTextInputPromptWithMessage:@"Enter your current password." completionBlock:^(BOOL userPressedOK, NSString * _Nullable userInput) {
                [self showSpinner:^{
                    NSString *password = userInput;
                    FIRAuthCredential *credential = [FIREmailPasswordAuthProvider credentialWithEmail:self.currentFIRUser.email password:password];
                    
                    [self.currentFIRUser reauthenticateWithCredential:credential completion:^(NSError *_Nullable error) {
                        // User re-authenticated.
                        if (error) {
                            // An error happened.
                            [self hideSpinner:^{
                                [self showMessagePrompt: error.localizedDescription];
                            }];
                            return;
                        }
                        
                        if (self.passwordTextField.text != [NSString stringWithFormat:@"11111"]){
                            if (self.passwordTextField.text != self.repeatPasswordTextField.text){
                                [self hideSpinner:^{
                                    [self showMessagePrompt:@"Passwords dont' match."];
                                }];
                                return;
                            }
                            [[FIRAuth auth].currentUser updatePassword:self.repeatPasswordTextField.text completion:^(NSError *_Nullable error) {
                                // Password has been changed.
                                if (error) {
                                    // An error happened.
                                    [self hideSpinner:^{
                                        [self showMessagePrompt: error.localizedDescription];
                                    }];
                                    return;
                                }
                                if (self.currentFIRUser.email != self.emailTextField.text ) {
                                    [self.currentFIRUser updateEmail:self.emailTextField.text completion:^(NSError *_Nullable error) {
                                        // Email has been changed.
                                        if (error) {
                                            // An error happened.
                                            [self hideSpinner:^{
                                                [self showMessagePrompt: error.localizedDescription];
                                            }];
                                            return;
                                        }
                                        [self.mutableValuesDictionary setObject:self.emailTextField.text forKey:@"email"];
                                        [self updateUserProfileValues];
                                    }];
                                } else{
                                    [self updateUserProfileValues];
                                }
                            }];
                        } else {
                            if (self.currentFIRUser.email != self.emailTextField.text ) {
                                [self.currentFIRUser updateEmail:self.emailTextField.text completion:^(NSError *_Nullable error) {
                                    // Email has been changed.
                                    if (error) {
                                        // An error happened.
                                        [self hideSpinner:^{
                                            [self showMessagePrompt: error.localizedDescription];
                                        }];
                                        return;
                                    }
                                    [self.mutableValuesDictionary setObject:self.emailTextField.text forKey:@"email"];
                                    [self updateUserProfileValues];
                                }];
                            } else{
                                [self updateUserProfileValues];
                            }
                        }
                        
                    }];
                }];
            }];
        }];
    }
}

- (void)updateUserProfileValues {
    [[[self.ref child:@"users"] child:self.currentFIRUser.uid] updateChildValues:(self.mutableValuesDictionary) withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        // Values have been updated;
        [self hideSpinner:^{
            if (error) {
                [self showMessagePrompt: error.localizedDescription];
            }
            return;
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)setEmail:(NSString*)email {
    [self.currentFIRUser updateEmail:email completion:^(NSError *_Nullable error) {
        // Email has been changed.
        if (error) {
            // An error happened.
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
    }];
}

- (IBAction)handleDeleteProfile:(id)sender {
    [[[self.ref child:@"users"] child:self.currentFIRUser.uid] removeValue];
    // Account from realtime database deleted.
    [self.currentFIRUser deleteWithCompletion:^(NSError *_Nullable error) {
        if (error) {
            // An error happened.
            [self showMessagePrompt: error.localizedDescription];
            return;
        } else {
            // Account deleted.
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


@end
