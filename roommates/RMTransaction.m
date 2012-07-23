//
//  RMTransaction.m
//  roommates
//
//  Created by andrew morton on 7/22/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMTransaction.h"
#import "RMExpense.h"
#import "RMReimbursal.h"
#import "RMHousehold.h"

static NSArray *cached = nil;

@implementation RMTransaction

// NOOP implementations to avoid warnings.
+ (NSString*)commentableType { return nil; }
- (NSString *)kind { return nil; }

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider {
    RKObjectMapping *expenseMapping = [provider objectMappingForClass:[RMExpense class]];
    RKObjectMapping *reimbursalMapping = [provider objectMappingForClass:[RMReimbursal class]];

    RKDynamicObjectMapping* dynamicMapping = [RKDynamicObjectMapping dynamicMapping];
    [dynamicMapping setObjectMapping:expenseMapping whenValueOfKeyPath:@"type" isEqualTo:@"Expense"];
    [dynamicMapping setObjectMapping:reimbursalMapping whenValueOfKeyPath:@"type" isEqualTo:@"Reimbursal"];
    [provider setObjectMapping:dynamicMapping forResourcePathPattern:@"/api/households/:householdId/transactions"];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
}

+ (void)fetchForHousehold:(NSNumber*) householdId
               withParams:(NSDictionary*) params
                onSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/transactions", householdId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path usingBlock:^(RKObjectLoader *loader) {
        loader.onDidLoadResponse = ^(RKResponse *response) {
            NSLog(@"%@", response.bodyAsString);
        };
        loader.onDidLoadObjects = ^(NSArray *objects) {
            cached = objects;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetched" object:self];
            success(objects);
        };
        loader.onDidFailWithError = ^(NSError *error) {
            cached = nil;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetchFailed" object:self];
            failure(error);
        };
    }];
}

+ (NSArray*) items
{
    return cached;
}

@synthesize transactionId, summary, amount, createdAt, creatorId, abilities, comments;

// FIXME: hack to work around this not being in a property.
- (NSNumber*)householdId
{
    return [RMHousehold current].householdId;
}

- (void) deleteItemOnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                   onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSLog(@"DELETE it....");
}

@end
