//
//  RMUser.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMUser.h"

@implementation RMUser

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore
{
    RKEntityMapping* mapping = [RKEntityMapping mappingForEntityForName:@"RMUser" inManagedObjectStore:objectStore];
    mapping.primaryKeyAttribute = @"userId";
    [mapping mapKeyPath:@"id" toAttribute:@"userId"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forKeyPath:@"users"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/users/:userId"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/users"];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/users/:userId"
                                      method:RKRequestMethodGET]];
}

+ (NSArray *)users
{
    @synchronized(self) {
        NSError *error;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"RMUser"];

        // Load them from the database and key by our id for lookups.
        NSMutableDictionary *users = [NSMutableDictionary dictionaryWithCapacity:50];
        for (RMUser *u in [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error]) {
            [users setObject:u forKey:u.userId];
        }
        return [NSDictionary dictionaryWithDictionary:users];
    }
}

+ (void) fetchItem:(NSNumber*) itemId
         OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
         onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/users/%i", itemId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path usingBlock:^(RKObjectLoader *loader) {
        loader.onDidLoadObject = ^(id whatLoaded) {
            NSLog(@"%@", whatLoaded);

            // Save the user to the database.
            NSError* error = nil;
            [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext save:&error];
            if (error) {
                NSLog(@"Save error: %@", error);
            }

            success(whatLoaded);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMItemFetched" object:[self class]];
        };
    }];
}

// Central point for formatting user names.
+ (NSString*)nameForId:(NSNumber*) userId
{
    RMUser *user = [RMUser.users objectForKey:userId];
    if (user == nil) {
        // If we don't have the user fire off fetch request to
        // get it locally. It'll probably show up after we build
        // this the first time but after that it should be cached.
        [RMUser fetchItem:userId OnSuccess:^(id object) {
            //
        } onFailure:^(NSError *error) {
            //
        }];
        return @"Unknown…";
    }
    return [user displayName];
}

@dynamic userId,
    firstName,
    lastName,
    displayName,
    fullName;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMUser (id: %@, first: %@, last: %@, display: %@)", self.userId, self.firstName, self.lastName, self.displayName];
}

// Be a little loose so we can compare to RMSession objects.
- (BOOL)isEqualToUser:(id)other
{
    return [other respondsToSelector:@selector(userId)] && [self.userId isEqualToNumber:[other userId]];
}
@end
