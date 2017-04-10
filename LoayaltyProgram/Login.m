//
//  Login.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 09.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Login.h"
#import "Firebase.h"

@interface Login () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRegisterButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation Login

- (void)viewDidLoad {
    [super viewDidLoad];

    [self textFieldSetup];
    [self buttonSetup];
    [self handleLoginRegisterChange];
}

- (void)textFieldSetup{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.repeatPasswordTextField.delegate = self;
}

- (void)buttonSetup{
    self.loginRegisterButton.layer.cornerRadius = 4.0;
}

- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.repeatPasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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

- (void)handleLoginRegisterChange{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.nameTextField.hidden = YES;
            self.repeatPasswordTextField.hidden = YES;
            [self.loginRegisterButton setTitle:@"Login" forState:UIControlStateNormal];
            break;
        case 1:
            self.nameTextField.hidden = NO;
            self.repeatPasswordTextField.hidden = NO;
            [self.loginRegisterButton setTitle:@"Registration" forState:UIControlStateNormal];
            break;
    }
}

- (void)handleLogin{
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                           
                             if (error){
                                 [self showAlertWithTitle:[error.userInfo objectForKey:@"error_name"]
                                              description:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                                 return;
                             }
                             [self dismissViewControllerAnimated:YES completion:nil];
                             NSLog(@"We successfully login user.");
                         }];
}

- (void)handleRegister{
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text
                               password:self.passwordTextField.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 
                                 if (error){
                                     [self showAlertWithTitle:[error.userInfo objectForKey:@"error_name"]
                                                  description:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                                     return;
                                 }
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 NSLog(@"We successfully register new user.");
                             }];
}

- (void)showAlertWithTitle:(NSString*)title description:(NSString*)description{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:description
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
