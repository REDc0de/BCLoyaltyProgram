//
//  Category.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 29.05.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Category.h"

@implementation Category

- (instancetype)init {
    return [self initWithName:@"" imageURL:@"" imageData:nil info:@"" items:nil uid:@""];
}

- (instancetype)initWithName:(NSString *)name imageURL:(NSString *)imageURL imageData:(NSData *)imageData info:(NSString *)info items:(NSMutableArray *)items uid:(NSString *)uid{
    self = [super init];
    if (self) {
        self.name = name;
        self.imageURL = imageURL;
        self.imageData = imageData;
        self.info = info;
        self.items = items;
        self.uid = uid;
    }
    return self;
}

@end
