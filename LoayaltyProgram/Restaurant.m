//
//  Restaurant.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 11.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (id)initWithName:(NSString *)name imageURL:(NSString *)imageURL info:(NSString *)info address:(NSString *)address tel:(NSString *)tel latitude:(float)latitude longitude:(float)longitude {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageURL = imageURL;
        self.info = info;
        self.address = address;
        self.tel = tel;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

@end
