//
//  User.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithUserName:(NSString*)name email:(NSString*)email profileImageURL:(NSString*)profileImageURL points:(int)points uid:(NSString*)uid{
    self = [super init];
    if (self){
        self.name = name;
        self.email = email;
        self.profileImageURL = profileImageURL;
        self.points = points;
        self.uid = uid;
    }
    return self;
}

@end
