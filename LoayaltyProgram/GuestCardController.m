//
//  GuestCardController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "GuestCardController.h"
#import "Firebase.h"

@interface GuestCardController ()

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (weak, nonatomic) IBOutlet UIView *guestCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *guestCardInfoView;
@property (weak, nonatomic) IBOutlet UIView *guestCardQRView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *userUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsNumberLabel;

@end

@implementation GuestCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    self.guestCardQRView.layer.cornerRadius = 10.0;
    self.guestCardInfoView.layer.cornerRadius = 10.0;
    self.guestCardContainerView.frame = CGRectOffset(self.guestCardContainerView.frame, 0, self.view.frame.size.height);
    
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
        
        UIImage *image = [UIImage imageWithCIImage:[self createQRForString:self.user.uid]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.qrCodeImageView.image = image;
            self.userUIDLabel.text = self.user.uid;
            self.pointsNumberLabel.text = [NSString stringWithFormat:@"%d",self.user.points];
        });
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showAlertWithError:error];
            return;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.4f animations:^{
        self.guestCardContainerView.frame = CGRectOffset(self.guestCardContainerView.frame, 0, -self.view.frame.size.height);
    }];
}

- (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    CGAffineTransform transform = CGAffineTransformMakeScale(40.0f, 40.0f); // scale by 40 times along both dimensions. Original width and height is equal 27
    CIImage *outputQRImage = [qrFilter.outputImage imageByApplyingTransform: transform];
    return outputQRImage; // qrFilter.outputImage - original image
}

- (IBAction)doneButtonAction:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        self.guestCardContainerView.frame = CGRectOffset(self.guestCardContainerView.frame, 0, self.view.frame.size.height);
    } completion:^(BOOL finished){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)infoAction:(id)sender {
    [UIView transitionWithView:self.guestCardContainerView
                      duration:0.8f
                       options:(self.guestCardInfoView.hidden ? UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        self.guestCardQRView.hidden =  !self.guestCardQRView.hidden ;
                        self.guestCardInfoView.hidden = !self.guestCardInfoView.hidden;
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
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
