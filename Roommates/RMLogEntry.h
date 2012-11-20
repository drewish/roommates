//
//  RMLogEntry.h
//  roommates
//
//  Created by andrew morton on 6/28/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"

@interface RMLogEntry : NSObject <RMObject, RMHouseholdable, RMFetchableList>

@property (nonatomic, retain) NSNumber* entryId;        // entry id
@property (nonatomic, retain) NSString* label;          // entry kind (shopping, todo, note, expense, reimbursal, comment) description – entry description
@property (nonatomic, retain) NSString* summary;        // entry description (renamed because it conflicts with the Objective-C description message).
@property (nonatomic, retain) NSString* action;         // entry action (e.g. “Posted by”)
@property (nonatomic, retain) NSNumber* actorId;        // id of user who performed specified action
@property (nonatomic, retain) NSDate* updatedAt;        // timestamp
@property (nonatomic, retain) NSNumber* loggableId;     // ID of related object
@property (nonatomic, retain) NSString* loggableType;   // type of related object

@end
