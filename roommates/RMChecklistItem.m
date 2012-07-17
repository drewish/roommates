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

    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/households/:householdId/checklist_items"];
}
     
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"checklistItemId"];
    [mapping mapAttributesFromSet:[NSArray arrayWithObjects:@"kind", @"title", 
                                   @"completed", @"abilities", @"comments", nil]];
    return mapping;
}

+ (void)fetchForHousehold:(NSNumber*) householdId
                OnSuccess:(RKObjectLoaderDidLoadObjectsBlock) success
                OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure
{
    NSString *path = [NSString stringWithFormat:@"/api/households/%i/checklist_items", householdId.intValue];
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


@synthesize checklistItemId, kind, title, completed, abilities, comments;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMChecklistItem (%@ id: %@, %@ '%@')", 
            self.kind, self.checklistItemId, self.completed, self.title];
}
@end
