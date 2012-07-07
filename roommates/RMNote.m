//
//  RMNote.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMNote.h"

@implementation RMNote

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/notes"];
}
     
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"noteId"];
    [mapping mapKeyPath:@"body" toAttribute:@"body"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"photo" toAttribute:@"photo"];
    [mapping mapKeyPath:@"abilities" toAttribute:@"abilities"];
    [mapping mapKeyPath:@"comments" toAttribute:@"comments"];
    return mapping;
}

+ (void)fetchForHousehold:(NSNumber*) householdId
                OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/notes", householdId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path usingBlock:^(RKObjectLoader *loader) {
        loader.onDidLoadObjects = success;
        loader.onDidFailWithError = failure;
    }];
}

@synthesize noteId, 
    body, 
    createdAt, 
    creatorId, 
    photo, 
    abilities, 
    comments;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMNote (id: %@, \"%@\" by User %@ at %@)", 
            self.noteId, self.body, self.creatorId, self.createdAt];
}
@end
