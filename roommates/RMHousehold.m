//
//  RMHousehold.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMHousehold.h"
#import "RMUser.h"

@implementation RMHousehold

static NSArray *cachedObjects = nil;
static RMHousehold *current = nil;

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore
{
    RKManagedObjectMapping* mapping = [self addMappingsTo:[RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households"];
}

+ (RKManagedObjectMapping*) addMappingsTo:(RKManagedObjectMapping*) mapping
{
    mapping.primaryKeyAttribute = @"householdId";
    [mapping mapKeyPath:@"id" toAttribute:@"householdId"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"current" toAttribute:@"current"];
//    [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:[RKObjectMapping mappingForClass:[RMUser class]]];
    return mapping;
}

+ (RMHousehold *)current
{
    // households inits this so make sure it's been called.
    [self households];
    return current;
}

+ (void)setCurrent:(RMHousehold*)household
{
    @synchronized(self) {
        for (RMHousehold *h in cachedObjects) {
            h.current = [NSNumber numberWithBool:NO];
        }
        current.current = [NSNumber numberWithBool:YES];
        current = household;

        // Save this to the local database.
        NSError* error = nil;
        [[RKObjectManager sharedManager].objectStore.managedObjectContextForCurrentThread save:&error];
        if (error) {
            NSLog(@"Save error: %@", error);
        }

        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"RMHouseholdSelected" object:current];
        
        // TODO Make a call to get this set server side.
    }
}

+ (NSArray *)households
{
    @synchronized(self) {
        // Load it from the database initially.
        if (cachedObjects == nil) {
            [self setHouseholds: [self objectsWithFetchRequest:[self fetchRequest]]];
        }
    }
    return cachedObjects;
}

+ (void)setHouseholds:(NSArray*)households
{
    @synchronized(self) {
        cachedObjects = households;
        for (RMHousehold *h in cachedObjects) {
            if ([h.current isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
                current = h;

                [[NSNotificationCenter defaultCenter] 
                 postNotificationName:@"RMHouseholdSelected" object:current];

                return;
            }
        }
        current = nil;
    }
}

+ (void)getHouseholdsOnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                     OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/api/households" usingBlock:^(RKObjectLoader *loader) {
        loader.onDidLoadObjects = ^(NSArray *households) {
            NSLog(@"Households: %@", households);

            // Save:
            NSError* error = nil;
            [[RKObjectManager sharedManager].objectStore.managedObjectContextForCurrentThread save:&error];
            if (error) {
                NSLog(@"Save error: %@", error);
            }

            [self setHouseholds: households];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetched" object:self];
            success(households);
        };
        loader.onDidFailWithError = ^(NSError *error) {
            [self setHouseholds:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetchFailed" object:self];
            failure(error);
        };
    }];
}

@dynamic householdId,
    displayName,
    current;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMHousehold (id: %@, displayName: %@ current: %@)", 
            self.householdId, self.displayName, self.current];
}

@end
