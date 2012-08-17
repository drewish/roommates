//
//  RMNote.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"
#import "RMHousehold.h"
#import "RMNote.h"
#import "RMComment.h"

static NSArray *cached = nil;
@implementation RMNote

+ (NSString*)commentableType
{
    return @"note";
}

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPath:@"id" toAttribute:@"noteId"];
    [mapping mapKeyPath:@"body" toAttribute:@"body"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"photo" toAttribute:@"photoURL"];
    [mapping mapKeyPath:@"abilities" toAttribute:@"abilities"];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments"
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider addObjectMapping:mapping];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/notes"];
}

+ (void) registerRoutesWith:(RKRouteSet*) routes {
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/notes/:noteId"
                                      method:RKRequestMethodDELETE]];
    [routes addRoute:[RKRoute routeWithClass:[self class]
                         resourcePathPattern:@"/api/households/:householdId/notes"
                                      method:RKRequestMethodAny]];
}

+ (void)fetchForHousehold:(NSNumber*) householdId
               withParams:(NSDictionary*) params
                onSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/notes", householdId.intValue];
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

+ (void) fetchItem:(NSNumber*) itemId
         OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
         onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;
{
    RMNote *item = [self new];
    item.noteId = itemId;
    [[RKObjectManager sharedManager] getObject:item usingBlock:^(RKObjectLoader *loader) {
        loader.onDidFailLoadWithError = ^(NSError *error) {
            NSLog(@"%@", error);
            failure(error);
        };
        loader.onDidLoadObject = ^(id whatLoaded) {
            NSLog(@"%@", whatLoaded);
            success(whatLoaded);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"RMItemFetched" object:[self class]];
        };
    }];
}

@synthesize noteId, 
    body,
    createdAt,
    creatorId,
    photoURL,
    photo,
    abilities,
    comments;

// FIXME: hack to work around this not being in a property.
- (NSNumber*)householdId
{
    return [RMHousehold current].householdId;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"RMNote (id: %@, \"%@\" by User %@ at %@)", 
            self.noteId, self.body, self.creatorId, self.createdAt];
}

- (BOOL) isDeletable {
    NSNumber *permission = [[self abilities] objectForKey:@"destroy"];
    return [permission boolValue];
}

- (void) deleteItemOnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                   onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    [[RKObjectManager sharedManager] deleteObject:self usingBlock:^(RKObjectLoader *loader) {
        loader.backgroundPolicy = RKRequestBackgroundPolicyContinue;

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
    }];
}

- (void) postOnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
             onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    RKObjectManager *mgr = [RKObjectManager sharedManager];

    [mgr postObject:self usingBlock:^(RKObjectLoader *loader) {
        RKParams* params = [RKParams params];
        [params setValue:body forParam:@"note[body]"];
        if (photo) {
            RKParamsAttachment *attachment = [params
                                              setData:UIImageJPEGRepresentation(photo, 0.7)
                                              MIMEType:@"image/jpeg"
                                              forParam:@"note[photo_file]"];
            attachment.fileName = @"image.jpg";
        }
        loader.params = params;

        loader.backgroundPolicy = RKRequestBackgroundPolicyContinue;

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
