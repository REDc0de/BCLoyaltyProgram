//
//  Company.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 03.06.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "Company.h"

@implementation Company

- (instancetype)init{
    return [self initWithName:@"" imageURL:@"" imageData:nil tel:@"" contactEmail:@"" feedbackEmail:@"" info:@""];
}

- (instancetype)initWithName:(NSString *)name imageURL:(NSString *)imageURL imageData:(NSData*)imageData tel:(NSString*)tel contactEmail:(NSString*)contactEmail feedbackEmail:(NSString*)feedbackEmail info:(NSString *)info {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageURL = imageURL;
        self.imageData = imageData;
        self.tel = tel;
        self.contactEmail =contactEmail;
        self.info = info;
    }
    return self;
}


@end
