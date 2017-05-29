//
//  User.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)init {
    return [self initWithUserName:@"" gender:@"" birthday:@"" phoneNumber:@"" email:@"" profileImageURL:@"" profileImageData:nil points:0 uid:@""];
}

- (instancetype)initWithUserName:(NSString *)name gender:(NSString *)gender birthday:(NSString *)birtday phoneNumber:(NSString *)phoneNumber email:(NSString *)email profileImageURL:(NSString *)profileImageURL profileImageData:(NSData*)profileImageData points:(int)points uid:(NSString *)uid {
    self = [super init];
    if (self){
        self.name = name;
        self.gender = gender;
        self.birthday = birtday;
        self.phoneNumber = phoneNumber;
        self.email = email;
        self.profileImageURL = profileImageURL;
        self.profileImageData = profileImageData;
        self.points = points;
        self.uid = uid;
    }
    return self;
}

@end
