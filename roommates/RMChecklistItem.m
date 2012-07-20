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
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"id" toAttribute:@"checklistItemId"];
    [mapping mapAttributesFromSet:[NSArray arrayWithObjects:@"kind", @"title",
                                   @"completed", @"abilities", nil]];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments" 
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items"];
    // This should work if my pull request gets accepted: https://github.com/RestKit/RestKit/pull/871
    //[provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items?kind=:kind"];
    // Use this fallback in the mean time.
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items?kind=todo"];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items?kind=shopping"];
}

+ (void)fetchForHousehold:(NSNumber*) householdId
               withParams:(NSDictionary*) params
                onSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/checklist_items", householdId.intValue];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[path stringByAppendingQueryParameters:params] usingBlock:^(RKObjectLoader *loader) {
        loader.onDidLoadObjects = ^(NSArray *objects) {
            NSLog(@"%@", objects);
            cached = objects;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMListFetched" object:self];
            success(objects);
        };
        loader.onDidFailLoadWithError = ^(NSError *error) {
            NSLog(@"%@", error);
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


@synthesize checklistItemId, kind, title, completed, abilities, comments;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMChecklistItem id: %@, %@ '%@' %@ comments)",
            self.checklistItemId, self.kind, self.title, [NSNumber numberWithInt:[self.comments count]]];
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
