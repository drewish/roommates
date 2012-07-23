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
    [mapping mapKeyPath:@"record.id" toAttribute:@"transactionId"];
    [mapping mapKeyPath:@"record.description" toAttribute:@"summary"];
    [mapping mapKeyPath:@"record.amount" toAttribute:@"amount"];
    [mapping mapKeyPath:@"record.created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"record.creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"record.abilities" toAttribute:@"abilities"];
    [mapping mapKeyPath:@"record.from_user_id" toAttribute:@"fromUserId"];
    [mapping mapKeyPath:@"record.to_user_id" toAttribute:@"toUserId"];

    // Hook the comments in too.
    [mapping mapKeyPath:@"record.comments" toRelationship:@"comments"
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
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

@end
