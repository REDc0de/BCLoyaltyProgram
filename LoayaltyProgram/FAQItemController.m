//
//  FAQItemController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "FAQItemController.h"

@interface FAQItemController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FAQItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.question.title;
    self.textView.text = self.question.info;
    [self.textView sizeToFit];
    self.textViewHeightConstraint.constant = self.textView.contentSize.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
