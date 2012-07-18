//
//  RMChecklistItem.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMChecklistItem.h"
#import "RMComment.h"

static NSArray *cached = nil;
@implementation RMChecklistItem

+ (NSString*)commentableType
{
    return @"checklist_item";
}

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments" 
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items?kind=:kind"];
}
     
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"checklistItemId"];
    [mapping mapAttributesFromSet:[NSArray arrayWithObjects:@"kind", @"title", 
                                   @"completed", @"abilities", @"comments", nil]];
    return mapping;
}

+ (void)fetchForHousehold:(NSNumber*) householdId
               withParams:(NSDictionary*) params
                onSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/checklist_items", householdId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[path stringByAppendingQueryParameters:params] usingBlock:^(RKObjectLoader *loader) {
        // TODO: We shouldn't have to specify this...
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[self class]];
        loader.objectMapping = [[self class] addMappingsTo:objectMapping];
        loader.onDidFailWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            cached = nil;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetchFailed" object:self];
            failure(error);
        };
        loader.onDidFailLoadWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            failure(error);
        };
        loader.onDidLoadObjects = ^(NSArray *objects) {
            NSLog(@"%@", objects);
            cached = objects;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetched" object:self];
            success(objects);
        };
        loader.onDidLoadResponse = ^(RKResponse *response) {
            NSLog(@"%@", response);
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
        };
    }];
}

+ (NSArray*) items
{
    return cached;
}


@synthesize checklistItemId, kind, title, completed, abilities, comments;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMChecklistItem (%@ id: %@, %@ '%@')", 
            self.kind, self.checklistItemId, self.completed, self.title];
}

- (void) deleteItemOnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                   onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    [[RKObjectManager sharedManager] deleteObject:self usingBlock:^(RKObjectLoader *loader) {
        loader.onDidFailWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            failure(error);
        };
        loader.onDidFailLoadWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            failure(error);
        };
        loader.onDidLoadObject = ^(id deletedItem) {
            NSLog(@"%@", deletedItem);
            success(deletedItem);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMItemRemoved" object:[self class]];
        };
        loader.onDidLoadResponse = ^(RKResponse *response) {
            NSLog(@"%@", response);
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
        };
    }];
}

@end
