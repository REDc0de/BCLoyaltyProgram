//
//  AboutUsController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "AboutUsController.h"
#import "UIViewController+Alerts.h"
#import <MessageUI/MessageUI.h>
#import "Firebase.h"

@interface AboutUsController ()<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;

@end

@implementation AboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    [self startObserve];
    [self updateUIContent];
    [self updateUIConstraints];
    [self imageViewSetup];
    [self makeRoundView:self.callButton];
    [self makeRoundView:self.mailButton];
}

- (void)startObserve {
    [[self.reference child:@"company"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.company.name = snapshot.value[@"name"];
        self.company.imageURL = snapshot.value[@"imageURL"];
        self.company.tel = snapshot.value[@"tel"];
        self.company.contactEmail = snapshot.value[@"contactEmail"];
        self.company.feedbackEmail = snapshot.value[@"feedbackEmail"];
        self.company.info = snapshot.value[@"info"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUIContent];
            [self updateUIConstraints];
            [self imageViewSetup];
        });
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
    }];
}

- (void)imageViewSetup {
    if (self.company.imageData){
        self.companyImageView.image = [UIImage imageWithData:self.company.imageData];
    } else{
        NSURL *url = [NSURL URLWithString:self.company.imageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.companyImageView.image = [UIImage imageWithData:data];
            });
        }] resume];
    }
}

- (void)makeRoundView:(UIView*)view{
    view.layer.cornerRadius = view.layer.frame.size.width/2;
    view.layer.masksToBounds = YES;
}

- (void)updateUIContent {
    self.navigationItem.title = self.company.name;
    self.textView.text = self.company.info;
}

- (void)updateUIConstraints {
    [self.textView sizeToFit];
    self.textViewHeightConstraint.constant = self.textView.contentSize.height;
}

- (IBAction)handleCall:(id)sender {
    NSString *telURL = [NSString stringWithFormat:@"tel:%@",self.company.tel];
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telURL]];
}

- (IBAction)handleMail:(id)sender {
    [self sendMailWithSubject:self.company.name message:@"" toRecipient:self.company.contactEmail];
}


#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMailWithSubject:(NSString*)subject message:(NSString*)message toRecipient:(NSString*)recipient {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:subject];
        [mail setMessageBody:message isHTML:NO];
        [mail setToRecipients:@[recipient]];
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else {
        [self showMessagePrompt:@"This device cannot send email"];
    }
}

@end
