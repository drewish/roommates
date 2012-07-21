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

@property (nonatomic, retain) NSNumber* checklistItemId; // ID of note
@property (nonatomic, retain) NSString* kind;            // KIND of checklist item (either ‘todo’ or ‘shopping’)
@property (nonatomic, retain) NSString* title;           // checklist item title
@property (nonatomic, retain) NSNumber* completed;       // creation time
@property (nonatomic, retain) NSDictionary* abilities;   // abilities hash for current user

@end
