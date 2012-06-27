//
//  RMUser.h
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RMUser : NSObject
@property (nonatomic, retain) NSNumber *userId;      // ID of the user
@property (nonatomic, retain) NSString *firstName;   // User’s first name
@property (nonatomic, retain) NSString *lastName;    // User’s last name
@property (nonatomic, retain) NSString *displayName; // User’s display name
@property (nonatomic, retain) NSString *fullName;    // User’s full name
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping;
@end
