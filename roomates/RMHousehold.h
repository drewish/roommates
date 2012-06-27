//
//  RMHousehold.h
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface RMHousehold : NSObject
@property (nonatomic, retain) NSNumber* householdId; // ID of the household
@property (nonatomic, retain) NSString* displayName; // Household nickname, or address if no nickname specified 
@property (nonatomic, retain) NSNumber* current;     // Whether it is the current household for given user

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping;

@end
