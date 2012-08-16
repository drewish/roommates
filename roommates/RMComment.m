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
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"id" toAttribute:@"commentId"];
    [mapping mapKeyPath:@"body" toAttribute:@"body"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/comments"];

    RKObjectMapping *serialization = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [serialization mapKeyPath:@"body" toAttribute:@"comment[body]"];
    [serialization mapKeyPath:@"commentableType" toAttribute:@"comment[commentable_type]"];
    [serialization mapKeyPath:@"commentableId" toAttribute:@"comment[commentable_id]"];
    [provider setSerializationMapping:serialization forClass:[self class]];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/comments"
                                      method:RKRequestMethodPOST]];
}

@synthesize commentId;
@synthesize body;
@synthesize createdAt;
@synthesize creatorId;
@synthesize commentableType;
@synthesize commentableId;

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    [[RKObjectManager sharedManager] postObject:self usingBlock:^(RKObjectLoader *loader) {
        loader.backgroundPolicy = RKRequestBackgroundPolicyContinue;

        loader.onDidFailLoadWithError = failure;
        loader.onDidLoadResponse = ^(RKResponse *response) {
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                
                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
        };
        loader.onDidLoadObject = ^(id whatLoaded) {
            NSLog(@"%@", whatLoaded);
            success(whatLoaded);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMItemAdded" object:[self class]];
        };
    }];
}

// FIXME: hack to work around this not being in a property.
- (NSNumber*)householdId
{
    return [RMHousehold current].householdId;
}

@end
