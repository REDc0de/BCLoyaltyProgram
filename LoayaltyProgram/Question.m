//
//  Question.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Question.h"

@implementation Question

- (instancetype)init{
    return [self initWithTitle:@"" info:@""];
}

- (instancetype)initWithTitle:(NSString *)title info:(NSString *)info {
    self = [super init];
    if (self) {
        self.title = title;
        self.info = info;
    }
    return self;
}

@end
