//
//  RMLogEntry.m
//  roommates
//
//  Created by andrew morton on 6/28/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMLogEntry.h"

static NSArray *cached = nil;
@implementation RMLogEntry

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"id" toAttribute:@"entryId"];
    [mapping mapKeyPath:@"label" toAttribute:@"label"];
    [mapping mapKeyPath:@"description" toAttribute:@"summary"];
    [mapping mapKeyPath:@"action" toAttribute:@"action"];
    [mapping mapKeyPath:@"actor_id" toAttribute:@"actorId"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"updatedAt"];
    [mapping mapKeyPath:@"loggable_id" toAttribute:@"loggableId"];
    [mapping mapKeyPath:@"loggable_type" toAttribute:@"loggableType"];
    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/log_entries"];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/log_entries"
                                      method:RKRequestMethodAny]];
}

+ (void)fetchForHousehold:(NSNumber*) householdId
               withParams:(NSDictionary*) params
                onSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/log_entries", householdId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path usingBlock:^(RKObjectLoader *loader) {
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

@synthesize entryId, 
    label,
    summary,
    action,
    actorId,
    updatedAt,
    loggableId,
    loggableType;
@synthesize householdId;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMLogEntry (id: %@, %@ %@ by %@ %@)", 
            self.entryId, self.label, self.action, self.actorId, self.summary];
}
@end
