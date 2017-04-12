//
//  News.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 12.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "News.h"

@implementation News

- (id)initWithTitle:(NSString *)title imageURL:(NSString *)imageURL info:(NSString *)info date:(NSString *)date {
    self = [super init];
    if (self) {
        self.title = title;
        self.imageURL = imageURL;
        self.info = info;
        self.date = date;
    }
    return self;
}

@end
