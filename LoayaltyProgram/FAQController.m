//
//  FAQController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "FAQController.h"
#import "Question.h"
#import "Firebase.h"
#import "FAQItemController.h"

@interface FAQController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *questions;

@end

@implementation FAQController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.questions = [[NSMutableArray alloc] init];
    [self observeFIRData];
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)observeFIRData {
    [[self.ref child:@"FAQ"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictionary = snapshot.value;
        Question *question = [[Question alloc] init];
        [question setValuesForKeysWithDictionary:dictionary];
        [self.questions addObject:question];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Question *question = [self.questions objectAtIndex:indexPath.row];
    cell.textLabel.text = question.title;
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FAQtoItem"]) {
        FAQItemController *upcoming = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Question *question = [self.questions objectAtIndex:indexPath.row];
        upcoming.question  = question;
    }
}


@end
