//
//  RMTransaction.h
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"
#import "RMUser.h"
#import "RMComment.h"

@interface RMTransaction : NSObject <RMObject, RMCommentable, RMDeletable, RMFetchableList>

@property (readonly) NSString* kind;
@property (nonatomic, retain) NSNumber* transactionId; // ID of note
@property (nonatomic, retain) NSString* summary;       // note body
@property (nonatomic, retain) NSDecimalNumber *amount; // reimbursal amount
@property (nonatomic, retain) NSDate* createdAt;       // creation time
@property (nonatomic, retain) NSNumber* creatorId;     // note creator

@end
