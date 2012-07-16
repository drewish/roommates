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
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];

    // Hook the comments in too.
    [mapping mapKeyPath:@"comments" toRelationship:@"comments" 
            withMapping:[provider objectMappingForClass:[RMComment class]]];

    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/notes"];
}
     
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
//    NSDateFormatter* dateFormatter = [NSDateFormatter new];
//    //                              2012-07-06T13:30:59-05:00
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
////    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
////    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//    mapping.dateFormatters = [NSArray arrayWithObject: dateFormatter];

    [mapping mapKeyPath:@"id" toAttribute:@"noteId"];
    [mapping mapKeyPath:@"body" toAttribute:@"body"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [mapping mapKeyPath:@"creator_id" toAttribute:@"creatorId"];
    [mapping mapKeyPath:@"photo" toAttribute:@"photo"];
    [mapping mapKeyPath:@"abilities" toAttribute:@"abilities"];

    return mapping;
}

+ (void) postNote:(NSString*) body
        onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
        onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    RKObjectManager *mgr = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/notes", [RMHousehold current].householdId.intValue];
    [mgr.client post:path usingBlock:^(RKRequest *request) {
        NSDictionary *note = [NSDictionary dictionaryWithObjectsAndKeys:
                              body, @"body", 
                              nil];
        request.params = [NSDictionary dictionaryWithObject:note forKey:@"note"];
        request.onDidLoadResponse = ^(RKResponse *response) {           
            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];

                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
            }
            else {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"RMItemAdded" object:[RMNote class]];

                success(note);
            }
        };
        request.onDidFailLoadWithError = failure;
    }];
}

+ (void)fetchForHousehold:(NSNumber*) householdId
                OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
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

@synthesize noteId, 
    body, 
    createdAt, 
    creatorId, 
    photo, 
    abilities, 
    comments;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMNote (id: %@, \"%@\" by User %@ at %@)", 
            self.noteId, self.body, self.creatorId, self.createdAt];
}
@end
