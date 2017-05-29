//
//  Product.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 29.05.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype)init {
    return [self initWithName:@"" imageURL:@"" imageData:nil info:@"" points:0 price:0];
}

- (instancetype)initWithName:(NSString *)name imageURL:(NSString *)imageURL imageData:(NSData *)imageData info:(NSString *)info points:(int)points price:(float)price {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageURL = imageURL;
        self.imageData = imageData;
        self.info = info;
        self.points = points;
        self.price = price;
    }
    return self;
}

@end
