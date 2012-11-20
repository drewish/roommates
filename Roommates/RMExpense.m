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
    [mapping mapKeyPath:@"id" toAttribute:@"transactionId"];
    [mapping mapKeyPath:@"description" toAttribute:@"summary"];
    [mapping mapKeyPath:@"amount" toAttribute:@"amount"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"abilities" toAttribute:@"abilities"];
    [mapping mapKeyPath:@"name" toAttribute:@"name"];
    [mapping mapKeyPath:@"photo" toAttribute:@"photoURL"];
    [mapping mapKeyPath:@"participations" toAttribute:@"participations"];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments"
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/expenses"];

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

@synthesize name, photoURL, photo, participations;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMExpense (id: %@ %@, %d comments)",
            self.transactionId, self.summary, self.comments.count];
}

- (NSString*) kind
{
    return @"Expense";
}

- (void) postWithParticipants:(NSArray*) userIds
                    onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
                    onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    RKObjectManager *mgr = [RKObjectManager sharedManager];

    [mgr postObject:self usingBlock:^(RKObjectLoader *loader) {
        RKParams* params = [RKParams params];
        [params setValue:self.name forParam:@"expense[name]"];
        [params setValue:self.amount forParam:@"expense[amount]"];
        for (NSNumber *uid in userIds) {
            [params setValue:uid forParam:@"expense[participant_ids][]"];
        }
        if (photo) {
            RKParamsAttachment *attachment = [params
                                              setData:UIImageJPEGRepresentation(photo, 0.7)
                                              MIMEType:@"image/jpeg"
                                              forParam:@"expense[photo_file]"];
            attachment.fileName = @"image.jpg";
        }
        //        expense[split_type] – empty or “custom” (optional)
        //        expense[amount_given] – hash where key is user id and value represents the amount user gave (already paid). Considered if split_type is “custom”.
        //        expense[amount_due] – hash where key is user id and value represents the amount user should pay (its share). Considered if split_type is “custom”.
        loader.params = params;

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
