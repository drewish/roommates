//
//  RMUser.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMUser.h"

@implementation RMUser
@synthesize userId,
    firstName,
    lastName,
    displayName,
    fullName;

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/users"];
}

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"userId"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    return mapping;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"RMUser (id: %@, first: %@, last: %@, display: %@)", self.userId, self.firstName, self.lastName, self.displayName];
}
@end
