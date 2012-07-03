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
    [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:[RKObjectMapping mappingForClass:[RMUser class]]];
    return mapping;
}

+ (RMHousehold *)current
{
    for (RMHousehold *h in [self households]) {
        if ([h.current isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
            return h;
        }
    }
    return nil;
}

+ (NSArray *)households
{
    @synchronized(self) {
        // Load it from the database initially.
        if (cachedObjects == nil) {
            cachedObjects = [self objectsWithFetchRequest:[self fetchRequest]];
        }
    }
    return cachedObjects;
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

            cachedObjects = households;
            success(cachedObjects);
        };
        loader.onDidFailWithError = ^(NSError *error) {
            cachedObjects = nil;
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
