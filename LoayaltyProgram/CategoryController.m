//
//  CategoryController.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "CategoryController.h"
#import "CategoryCell.h"
#import "Firebase.h"
#import "UIViewController+Alerts.h"

@interface CategoryController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation CategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.products = [[NSMutableArray alloc] init];
    self.imageCache = [[NSCache alloc] init];
    self.navigationItem.title = self.category.name;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.category.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(CategoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.productImageView.image = nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(CategoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = [self.category.items objectAtIndex:indexPath.row];
    
    cell.productNameLabel.text = product.name;
    cell.productInfoTextView.text = product.info;
    cell.priceAndPointsLabel.text = [NSString stringWithFormat:@"$%.2f",product.price];
    
    UIImage *image = [self.imageCache objectForKey:product.imageURL];
    if (image){
        cell.productImageView.image = image;
        return;
    }
    if(product.imageData){
        UIImage *image = [UIImage imageWithData:product.imageData];
        [self.imageCache setObject:image forKey:product.imageURL];
        cell.productImageView.image = image;
    } else{
    
    NSURL *url = [NSURL URLWithString:product.imageURL];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
        product.imageData = data;
        UIImage *image = [UIImage imageWithData:data];
        [self.imageCache setObject:image forKey:product.imageURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.productImageView.image = image;
        });
    }] resume];
    }
}


@end
