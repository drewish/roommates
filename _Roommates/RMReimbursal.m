//
//  RMReimbursal.m
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMReimbursal.h"

@implementation RMReimbursal

+ (NSString*)commentableType
{
    return @"reimbursal";
}

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"id" toAttribute:@"transactionId"];
    [mapping mapKeyPath:@"description" toAttribute:@"summary"];
    [mapping mapKeyPath:@"amount" toAttribute:@"amount"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"abilities" toAttribute:@"abilities"];
    [mapping mapKeyPath:@"from_user_id" toAttribute:@"fromUserId"];
    [mapping mapKeyPath:@"to_user_id" toAttribute:@"toUserId"];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments"
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/reimbursals"];

    RKObjectMapping *serialization = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [serialization mapKeyPath:@"amount" toAttribute:@"reimbursal[amount]"];
    [serialization mapKeyPath:@"fromUserId" toAttribute:@"reimbursal[from_user_id]"];
    [serialization mapKeyPath:@"toUserId" toAttribute:@"reimbursal[to_user_id]"];
    [provider setSerializationMapping:serialization forClass:[self class]];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/reimbursals"
                                      method:RKRequestMethodPOST]];
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/reimbursals/:transactionId"
                                      method:RKRequestMethodDELETE]];
}

@synthesize toUserId, fromUserId;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMRembursal (id: %@ %@, %d comments)",
            self.transactionId, self.summary, self.comments.count];
}

- (NSString*) kind
{
    return @"Expense";
}

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    RKObjectManager *mgr = [RKObjectManager sharedManager];
    
    [mgr postObject:self usingBlock:^(RKObjectLoader *loader) {
        loader.backgroundPolicy = RKRequestBackgroundPolicyContinue;

        loader.onDidLoadResponse = ^(RKResponse *response) {
            NSLog(@"%@", response);
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
        };
        loader.onDidFailLoadWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            failure(error);
        };
        loader.onDidLoadObject = ^(id whatLoaded) {
            NSLog(@"%@", whatLoaded);
            success(whatLoaded);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMItemAdded" object:[self class]];
        };
    }];
}

@end
