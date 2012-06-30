//
//  RMSession.m
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"

@implementation RMSession
@synthesize avatar, apiToken;


// FIXME: this probably isn't the best way to handle this since they 
// need to call startSessionEmail:... before this is initialized but 
// I just need to get this working so I can have access to it. I'll 
// circle back later and fix this.
static RMSession *gInstance = nil;
+ (RMSession *)instance
{
    return(gInstance);
}

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider 
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/sessions"];
}

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [super addMappingsTo:mapping];
    [mapping mapKeyPath:@"avatar" toAttribute:@"avatar"];
    [mapping mapKeyPath:@"api_token" toAttribute:@"apiToken"];
    return mapping;
}

+ (void)startSessionEmail:(NSString*) email Password:(NSString*) password
                OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success 
                    OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure {
    // Wipe the old session. TODO: should probably fire off a 
    // DELETE /api/session to kill it off server side.
    @synchronized(self)
    {
        gInstance = nil;
    }

    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/api/sessions" usingBlock:^(RKObjectLoader *loader) {
        loader.method = RKRequestMethodPOST;
        loader.params = [NSDictionary dictionaryWithObjectsAndKeys:
                         email, @"email", 
                         password, @"password", 
                         nil];
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[RMSession class]];        
        loader.objectMapping = [RMSession addMappingsTo:objectMapping];
        loader.onDidLoadObject = ^(RMSession *session) {
            // Store it into our singleton... It'd be better if we could just 
            // have them overwrite our existing object.
            @synchronized(self)
            {
                gInstance = session;
            }
            
            // Put our auth token into the parameter list for future requests.
            NSString *val = [NSString stringWithFormat:@"Token token=\"%@\"", session.apiToken];
            [[RKObjectManager sharedManager].client setValue:val forHTTPHeaderField:@"Authorization"];

            success(session);
        };
        loader.onDidFailWithError = failure;
    }];
}
@end
