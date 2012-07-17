//
//  RMComment.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMComment.h"
#import "RMData.h"

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

+ (void) post:(NSString*) body 
         toId:(NSNumber*) commentableId ofType:(NSString*) commentableType
    onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
    onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    RKObjectManager *mgr = [RKObjectManager sharedManager];
    [mgr.client post:@"/api/comments" usingBlock:^(RKRequest *request) {
        // comment[body] – body of comment (required)
        // comment[commentable_type] – type of commentable object (required, [checklist_item, note, expense or reimbursal])
        // comment[commentable_id] – the ID of commentable object (required)
        
        NSDictionary *comment = [NSDictionary dictionaryWithObjectsAndKeys:
                                 body, @"body", 
                                 commentableType, @"commentable_type", 
                                 commentableId, @"commentable_id", 
                                 nil];
        request.params = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
        request.onDidLoadResponse = ^(RKResponse *response) {
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                
                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
            else {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"RMItemAdded" object:[RMComment class]];
                
                success(comment);
            }
        };
        request.onDidFailLoadWithError = failure;
    }];
}

@synthesize commentId, body, createdAt, creatorId;

// FIXME: hack to work around this not being in a property.
- (NSNumber*)householdId
{
    return [RMHousehold current].householdId;
}

@end
