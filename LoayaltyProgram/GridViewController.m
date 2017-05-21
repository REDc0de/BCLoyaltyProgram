//
//  GridViewController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 21.05.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textviewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textField;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

    [self.textField sizeToFit];
    self.textviewHeightConstraint.constant = self.textField.contentSize.height;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
