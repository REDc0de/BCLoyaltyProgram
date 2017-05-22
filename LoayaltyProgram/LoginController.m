//
//  Login.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 09.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "LoginController.h"
#import "Firebase.h"

@interface LoginController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRegisterButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *genderPickerData;

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
    [self genderPickerViewSetup];
    [self datePickerSetup];
   }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}


#pragma mark - TextField Move Up

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = self.loginRegisterButton.frame.origin;
    CGFloat buttonHeight = self.loginRegisterButton.frame.size.height;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + 5);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
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
    
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateBirthdayTextField:) forControlEvents:UIControlEventValueChanged];
    [self.birthdayTextField setInputView:datePicker];
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0,0, self.view.frame.size.width, 44)];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(dismissKeyboard)];
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.birthdayTextField.inputAccessoryView = myToolbar;
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
    self.genderPickerData = @[@"male",@"female"];
    
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
    self.phoneNumberTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.birthdayTextField resignFirstResponder];
    [self.genderTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
    [self.view setNeedsUpdateConstraints];
}

- (void)updateUIForLoggin {
    self.nameTextField.hidden = YES;
    self.genderTextField.hidden = YES;
    self.birthdayTextField.hidden = YES;
    self.phoneNumberTextField.hidden = YES;
    self.profileImageView.userInteractionEnabled = NO;
    self.profileImageView.image = [UIImage imageNamed:@"Logo.png"];
    [self.loginRegisterButton setTitle:@"Login" forState:UIControlStateNormal];
}

- (void)updateUIForRegistration {
    self.nameTextField.hidden = NO;
    self.genderTextField.hidden = NO;
    self.birthdayTextField.hidden = NO;
    self.phoneNumberTextField.hidden = NO;
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
    NSString *gender = self.genderTextField.text;
    NSString *birthday = self.birthdayTextField.text;
    NSString *phoneNumber = self.phoneNumberTextField.text;
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
                                                                             @"gender": gender,
                                                                            @"birtday": birthday,
                                                                        @"phoneNumber": phoneNumber,
                                                                              @"email": email,
                                                                             @"points": @0,
                                                                    @"profileImageURL": profileImageURL,
                                                                   @"registrationDate": [NSString stringWithFormat:@"%@",[NSDate date]]};
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
