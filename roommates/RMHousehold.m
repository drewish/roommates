//
//  RMHousehold.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"
#import "RMHousehold.h"
#import "RMUser.h"

@implementation RMHousehold

static NSArray *cachedObjects = nil;
static RMHousehold *current = nil;

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore
{
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore];
    mapping.primaryKeyAttribute = @"householdId";
    [mapping mapKeyPath:@"id" toAttribute:@"householdId"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"current" toAttribute:@"current"];

    RKObjectMappingDefinition *m  = [provider objectMappingForClass:[RMUser class]];
    [mapping mapKeyPath:@"users" toRelationship:@"users"
            withMapping:m];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households"];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households"
                                      method:RKRequestMethodGET]];
}

+ (RMHousehold *)current
{
    // households inits this so make sure it's been called.
    [self households];
    return current;
}

// This version is only called by the users of the class, we manage current
// ourselves.
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
            if ([h.current isEqualToNumber:[NSNumber numberWithBool:YES]]) {
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
    current,
    users;

// FIXME: this shouldn't be in here. this class shouldn't need to know about 
// session ot know who the current user is.
- (NSArray *)userSorted
{
    // Sort users by
    NSNumber *yourId = RMSession.instance.userId;
    NSSortDescriptor *isYouDescriptor =
    [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *n1 = [NSNumber numberWithBool:[obj1 isEqualToNumber:yourId]];
        NSNumber *n2 = [NSNumber numberWithBool:[obj2 isEqualToNumber:yourId]];

        return [n2 compare: n1];
    }];
    NSSortDescriptor *nameDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"displayName"
                                 ascending:YES
                                  selector:@selector(localizedCaseInsensitiveCompare:)];

    NSArray *descriptors = @[isYouDescriptor, nameDescriptor];
    return [[[self users] allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"RMHousehold (id: %@, displayName: %@ current: %@)", 
            self.householdId, self.displayName, self.current];
}

@end
