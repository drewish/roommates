//
//  RMChecklistItem.h
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMObject.h"
#import "RMComment.h"

@interface RMChecklistItem : NSObject <RMObject, RMCommentable, RMDeletable, RMHouseholdable, RMFetchableList>

+ (void) postItem:(NSString*) title
             kind:(NSString*) kind
        onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
        onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;
//+ (void) getItem:(NSNumber*) itemId
//       OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
//       onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber* checklistItemId; // ID of note
@property (nonatomic, retain) NSString* kind;            // KIND of checklist item (either ‘todo’ or ‘shopping’)
@property (nonatomic, retain) NSString* title;           // checklist item title
@property (nonatomic, retain) NSNumber* completed;       // creation time

@end
