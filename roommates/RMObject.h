//
//  RMObject.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

// For temporal data.
@protocol RMObject <NSObject>
+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider;
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping;
@end

// For data stored in the database.
@protocol RMManagedObject <NSObject>
+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore;
+ (RKManagedObjectMapping*) addMappingsTo:(RKManagedObjectMapping*) mapping;
@end

@protocol RMFetchableList <NSObject>
+ (void)fetchForHousehold:(NSNumber*) householdId
                OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;
+ (NSArray*) items;
@end

// TODO: Ideally we'd be setting this when we fetch objects...
@protocol RMHouseholdable <NSObject>
@property (readonly) NSNumber* householdId;
@end

