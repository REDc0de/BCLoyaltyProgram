//
//  GuestCardController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "GuestCardController.h"

@interface GuestCardController ()

@property (weak, nonatomic) IBOutlet UIView *guestCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *guestCardInfoView;
@property (weak, nonatomic) IBOutlet UIView *guestCardQRView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation GuestCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.guestCardQRView.layer.cornerRadius = 10.0;
    self.guestCardInfoView.layer.cornerRadius = 10.0;
    self.guestCardContainerView.frame = CGRectOffset(self.guestCardContainerView.frame, 0, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageWithCIImage:[self createQRForString:@"QR code generator test"]];
    self.qrCodeImageView.image = image;
    
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

@end
