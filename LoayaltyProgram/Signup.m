//
//  Signup.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 09.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Signup.h"

@interface Signup () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *telephoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation Signup

- (void)viewDidLoad {
    [super viewDidLoad];

    [self buttonSetUp];
    [self textFieldSetup];
}

- (void)textFieldSetup{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.nameTextField.delegate = self;
    self.birthdayTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.telephoneTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.rePasswordTextField.delegate = self;
}

- (void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.birthdayTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.telephoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.rePasswordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

- (void)buttonSetUp{
    self.signupButton.layer.cornerRadius = 4.0;
}

- (IBAction)handleCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSignUp:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
