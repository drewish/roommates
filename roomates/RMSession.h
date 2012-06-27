//
//  RMSession.h
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMUser.h"

@interface RMSession : RMUser
@property (nonatomic, retain) NSURL *avatar;         // User’s avatar url
@property (nonatomic, retain) NSString *apiToken;    // Token that should be used for accessing the api
@end
