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
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore];
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
        // Load them from the database and key by our id for lookups.
        NSMutableDictionary *users = [NSMutableDictionary dictionaryWithCapacity:50];
        for (RMUser *u in [self objectsWithFetchRequest:[self fetchRequest]]) {
            [users setObject:u forKey:u.userId];
        }
        return [NSDictionary dictionaryWithDictionary:users];
    }
}

// Central point for formatting user names.
+ (NSString*)nameForId:(NSNumber*) userId
{
    return [[self.users objectForKey: userId] displayName];
}

@dynamic userId,
    firstName,
    lastName,
    displayName,
    fullName;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMUser (id: %@, first: %@, last: %@, display: %@)", self.userId, self.firstName, self.lastName, self.displayName];
}

- (BOOL)isEqualToUser:(RMUser*)other {
    return [self.userId isEqualToNumber:other.userId];
}
@end
