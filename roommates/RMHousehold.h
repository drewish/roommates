//
//  RMHousehold.h
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMManagedObject.h"

@interface RMHousehold : NSManagedObject <RMManagedObject>
+ (RMHousehold *)current;
+ (NSArray *)households;
+ (void)getHouseholdsOnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                     OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber* householdId; // ID of the household
@property (nonatomic, retain) NSString* displayName; // Household nickname, or address if no nickname specified
@property (nonatomic, retain) NSNumber* current;     // Whether it is the current household for given user

@end
