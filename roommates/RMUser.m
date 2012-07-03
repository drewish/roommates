//
//  RMUser.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMUser.h"

@implementation RMUser

static NSArray *cachedObjects = nil;

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore
{
    RKManagedObjectMapping* mapping = [self addMappingsTo:[RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:objectStore]];
    [provider setObjectMapping:mapping forKeyPath:@"users"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/users/:userId"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/users"];
}

+ (RKManagedObjectMapping*) addMappingsTo:(RKManagedObjectMapping*) mapping
{
    mapping.primaryKeyAttribute = @"userId";
    [mapping mapKeyPath:@"id" toAttribute:@"userId"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    return mapping;
}

+ (NSArray *)users
{
    @synchronized(self) {
        // Load it from the database initially.
        if (cachedObjects == nil) {
            cachedObjects = [self objectsWithFetchRequest:[self fetchRequest]];
        }
    }
    return cachedObjects;
}

@dynamic userId,
    firstName,
    lastName,
    displayName,
    fullName;


- (NSString*)description {
	return [NSString stringWithFormat:@"RMUser (id: %@, first: %@, last: %@, display: %@)", self.userId, self.firstName, self.lastName, self.displayName];
}
@end