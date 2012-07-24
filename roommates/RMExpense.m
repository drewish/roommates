//
//  RMExpense.m
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMExpense.h"

@implementation RMExpense

+ (NSString*)commentableType
{
    return @"expense";
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
    [mapping mapKeyPath:@"record.name" toAttribute:@"name"];
    [mapping mapKeyPath:@"record.photo" toAttribute:@"photo"];
    [mapping mapKeyPath:@"record.participations" toAttribute:@"participations"];

    // Hook the comments in too.
    [mapping mapKeyPath:@"record.comments" toRelationship:@"comments"
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];

    RKObjectMapping *serialization = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [serialization mapKeyPath:@"amount" toAttribute:@"expense[amount]"];
    [serialization mapKeyPath:@"name" toAttribute:@"expense[name]"];
    [serialization mapKeyPath:@"participations" toAttribute:@"expense[participant_ids]"];
    // TODO: Figure out how to map the rest of these.
//    [serialization mapKeyPath:@"splitType?" toAttribute:@"expense[split_type]"];
//    [serialization mapKeyPath:@"photo" toAttribute:@"expense[photo]"];
//    expense[split_type] – empty or “custom” (optional)
//    expense[amount_given] – hash where key is user id and value represents the amount user gave (already paid). Considered if split_type is “custom”.
//    expense[amount_due] – hash where key is user id and value represents the amount user should pay (its share). Considered if split_type is “custom”.
    [provider setSerializationMapping:serialization forClass:[self class]];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/expenses"
                                      method:RKRequestMethodPOST]];
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/expenses/:transactionId"
                                      method:RKRequestMethodDELETE]];
}

@synthesize name, photo, participations;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMExpense (id: %@ %@, %d comments)",
            self.transactionId, self.summary, self.comments.count];
}

- (NSString*) kind
{
    return @"Expense";
}

@end
