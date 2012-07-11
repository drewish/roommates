//
//  RMComment.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMComment.h"

@implementation RMComment

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider addObjectMapping:mapping];
    // Classes that use the comments are responsible for associating the mapping
    // with the keyPath:
    // [mapping mapKeyPath:@"comments" toRelationship:@"comments" 
    //         withMapping:[provider objectMappingForClass:[RMComment class]]];
}

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"commentId"];
    [mapping mapKeyPath:@"body" toAttribute:@"body"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];

    return mapping;
}

@synthesize commentId, body, createdAt, creatorId;

@end
