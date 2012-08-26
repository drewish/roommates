//
//  RMNote.h
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMObject.h"
#import "RMComment.h"

@interface RMNote : NSObject <RMObject, RMCommentable, RMDeletable, RMHouseholdable, RMFetchableList>

+ (void) fetchItem:(NSNumber*) itemId
         OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
         onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber* noteId;    // ID of note
@property (nonatomic, retain) NSString* body;      // note body
@property (nonatomic, retain) NSDate* createdAt;   // creation time
@property (nonatomic, retain) NSNumber* creatorId; // note creator
@property (nonatomic, retain) NSURL* photoURL;     // photo url
@property (nonatomic, retain) UIImage* photo;      // image to upload

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@end
