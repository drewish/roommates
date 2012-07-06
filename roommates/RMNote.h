//
//  RMNote.h
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMObject.h"

@interface RMNote : NSObject <RMObject>
+ (void)fetchForHousehold:(NSNumber*) householdId
                OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber* noteId;        // ID of note
@property (nonatomic, retain) NSString* body;          // note body
@property (nonatomic, retain) NSNumber* createdAt;    // creation time
@property (nonatomic, retain) NSNumber* creatorId;    // note creator
@property (nonatomic, retain) NSString* photo;         // photo url
@property (nonatomic, retain) NSDictionary* abilities; // abilities hash for current user
@property (nonatomic, retain) NSArray* comments;       // array of comments

@end
