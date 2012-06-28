//
//  RMLogEntry.h
//  roomates
//
//  Created by andrew morton on 6/28/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMDataObject.h"

@interface RMLogEntry : RMDataObject
@property (nonatomic, retain) NSNumber* entryId;        // entry id
@property (nonatomic, retain) NSString* label;          // entry kind (shopping, todo, note, expense, reimbursal, comment) description – entry description
@property (nonatomic, retain) NSString* action;         // entry action (e.g. “Posted by”)
@property (nonatomic, retain) NSNumber* actorId;        // id of user who performed specified action
@property (nonatomic, retain) NSNumber* updatedAt;      // timestamp
@property (nonatomic, retain) NSNumber* loggableId;     // ID of related object
@property (nonatomic, retain) NSString* loggableType;   // type of related object

@property (nonatomic, retain) NSNumber* householdId;        // TESTING THIS to see if it'll get it working.

+ (void)getLogEntriesForHousehold:(NSNumber*) householdId
                        OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success 
                        OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;
@end
