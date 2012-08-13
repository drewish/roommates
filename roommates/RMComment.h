//
//  RMComment.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"

@protocol RMCommentable
// Type of commentable object (required, [checklist_item, note, expense or reimbursal])
+ (NSString*)commentableType;

@property (nonatomic, retain) NSArray* comments;

@end

@interface RMComment : NSObject <RMObject, RMHouseholdable>

@property (nonatomic, retain) NSNumber* commentId;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSDate* createdAt;
@property (nonatomic, retain) NSNumber* creatorId;
@property (nonatomic, retain) NSString* commentableType;    // Used for posting, generally will be nil.
@property (nonatomic, retain) NSNumber* commentableId;      // Used for posting, generally will be nil.

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@end
