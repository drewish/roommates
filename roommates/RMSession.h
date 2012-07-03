//
//  RMSession.h
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"

@interface RMSession : NSObject <RMObject>
+ (RMSession *)instance;
+ (void)startSessionEmail:(NSString*) email Password:(NSString*) password
                OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber *userId;      // ID of the user
@property (nonatomic, retain) NSString *firstName;   // User’s first name
@property (nonatomic, retain) NSString *lastName;    // User’s last name
@property (nonatomic, retain) NSString *displayName; // User’s display name
@property (nonatomic, retain) NSString *fullName;    // User’s full name
@property (nonatomic, retain) NSURL *avatar;         // User’s avatar url
@property (nonatomic, retain) NSString *apiToken;    // Token that should be used for accessing the api
@end
