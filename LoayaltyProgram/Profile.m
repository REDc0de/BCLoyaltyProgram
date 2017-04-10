//
//  Profile.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Profile.h"
#import "Firebase.h"

@interface Profile ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation Profile

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.userNameLabel.text = [[FIRAuth auth] currentUser].email;
    if ([[FIRAuth auth] currentUser].uid == nil){
        [self handleSignout:nil];
    }
}

- (IBAction)handleSignout:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        if (signOutError){
            [self showAlertWithTitle:[signOutError.userInfo objectForKey:@"error_name"]
                         description:[signOutError.userInfo objectForKey:@"NSLocalizedDescription"]];
            return;
        }
        return;
    }
    [self performSegueWithIdentifier:@"profileToLogin" sender:self];
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
