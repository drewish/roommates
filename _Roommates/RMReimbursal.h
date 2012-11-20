//
//  RMReimbursal.h
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMTransaction.h"

@interface RMReimbursal : RMTransaction

@property (nonatomic, retain) NSNumber *fromUserId; // user who gives the amount
@property (nonatomic, retain) NSNumber *toUserId;   // user who receives the amount

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@end
