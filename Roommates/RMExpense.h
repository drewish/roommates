//
//  RMExpense.h
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMTransaction.h"

@interface RMExpense : RMTransaction

@property (nonatomic, retain) NSString* name;  // name of the expense
@property (nonatomic, retain) NSURL* photoURL; // photo url
@property (nonatomic, retain) UIImage* photo;  // image to upload
// each user participation within expense (where keys are user ids)
@property (nonatomic, retain) NSDictionary* participations;

- (void) postWithParticipants:(NSArray*) userIds
                    onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
                    onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@end
